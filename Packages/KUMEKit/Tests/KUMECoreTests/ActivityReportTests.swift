import Foundation
import Testing
@testable import KUMECore

struct ActivityReportTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        return calendar
    }

    private func withStore(_ body: (UsageStatsStore) throws -> Void) throws {
        let store = UsageStatsStore(directory: FileManager.default.temporaryDirectory
            .appendingPathComponent("kume-activity-\(UUID().uuidString)"))
        defer { try? FileManager.default.removeItem(at: store.directory) }
        try body(store)
    }

    private func add(_ characters: Int, day: String, to store: UsageStatsStore) throws {
        var activity = DayActivity()
        activity.add(han: characters, words: 0, hour: 12, app: "test.app")
        try store.mergeActivity(activity, into: day)
    }

    @Test func rejectsInvalidAndNoncanonicalDates() {
        for key in ["2026-02-30", "2026-13-01", "2026-00-01", "2026-1-01",
                    "2026-01-1", "2026-extra-01-01", "-2026-01-01", "2026--01-01"] {
            #expect(UsageStatsStore.date(key, calendar: calendar) == nil, "\(key)")
        }
        #expect(UsageStatsStore.date("2024-02-29", calendar: calendar) != nil)
        #expect(UsageStatsStore.date("2026-02-29", calendar: calendar) == nil)
    }

    @Test func invalidFilenamesDoNotAffectTotals() throws {
        try withStore { store in
            try add(3, day: "2026-10-09", to: store)
            try add(100, day: "2026-02-30", to: store)
            try add(200, day: "notes", to: store)
            let now = try #require(UsageStatsStore.date("2026-10-09", calendar: calendar))
            let report = store.report(now: now, calendar: calendar)
            #expect(report.lifetime == 3)
            #expect(report.activeDays == 1)
            #expect(report.peak?.characters == 3)
        }
    }

    @Test func sparseHistoryAndTiedPeaksAreStable() throws {
        try withStore { store in
            for day in ["2000-01-01", "2000-01-02", "2000-01-03", "2026-10-07", "2026-10-08"] {
                try add(3, day: day, to: store)
            }
            let now = try #require(UsageStatsStore.date("2026-10-09", calendar: calendar))
            let report = store.report(now: now, calendar: calendar)
            #expect(report.longestStreak == 3)
            #expect(report.streak == 2) // Today's empty record must not break yesterday's run.
            #expect(report.activeDays == 5 && report.lifetime == 15)
            #expect(report.firstDay == UsageStatsStore.date("2000-01-01", calendar: calendar))
            #expect(report.peak?.date == report.firstDay) // Earliest day wins a tie.
            #expect(report.days.count == ActivityReport.historyDays)

            let tomorrow = try #require(calendar.date(byAdding: .day, value: 1, to: now))
            #expect(store.report(now: tomorrow, calendar: calendar).streak == 0)
        }
    }

    @Test(arguments: [("2026-03-07", "2026-03-08", "2026-03-09"),
                      ("2026-10-31", "2026-11-01", "2026-11-02")])
    func streakUsesCalendarDaysAcrossDaylightSaving(_ days: (String, String, String)) throws {
        try withStore { store in
            for day in [days.0, days.1, days.2] { try add(2, day: day, to: store) }
            let now = try #require(UsageStatsStore.date(days.2, calendar: calendar))
            let report = store.report(now: now, calendar: calendar)
            #expect(report.streak == 3 && report.longestStreak == 3)
            #expect(report.today == 2 && report.yesterday == 2)
        }
    }

    @Test func emptyAndFutureRecordsDoNotExtendStreaks() throws {
        try withStore { store in
            try add(2, day: "2026-10-08", to: store)
            try add(0, day: "2026-10-09", to: store)
            try add(2, day: "2026-10-10", to: store)
            let now = try #require(UsageStatsStore.date("2026-10-09", calendar: calendar))
            let report = store.report(now: now, calendar: calendar)
            #expect(report.streak == 1 && report.longestStreak == 1)
        }
    }
}
