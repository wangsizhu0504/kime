// swift-tools-version: 6.2
import PackageDescription

let strictSwift: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
]

let package = Package(
    name: "KUMEKit",
    defaultLocalization: "zh-Hans",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "RimeKit", targets: ["RimeKit"]),
        .library(name: "KUMECore", targets: ["KUMECore"]),
        .library(name: "KUMEPanel", targets: ["KUMEPanel"]),
        .library(name: "KUMEAI", targets: ["KUMEAI"]),
        .executable(name: "kume", targets: ["kume"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "6.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.0"),
    ],
    targets: [
        // librime 1.17 prebuilt, assembled by scripts/fetch-librime.sh.
        .binaryTarget(name: "CRime", path: "Frameworks/CRime.xcframework"),

        // Thin, typed Swift wrapper over the librime C API.
        .target(name: "RimeKit", dependencies: ["CRime"], swiftSettings: strictSwift),

        // Configuration model, patch writer, importer, dictionary packages.
        .target(
            name: "KUMECore",
            dependencies: [.product(name: "Yams", package: "Yams")],
            resources: [.copy("Resources/catalog.json"), .copy("Resources/registry.json")],
            swiftSettings: strictSwift
        ),

        // AppKit candidate panel shared by the input method and the settings preview.
        .target(name: "KUMEPanel", dependencies: ["KUMECore"], swiftSettings: strictSwift),

        // Optional AI assistant. Never touches composition buffers or user dictionaries.
        .target(name: "KUMEAI", dependencies: ["KUMECore"], swiftSettings: strictSwift),

        .executableTarget(
            name: "kume",
            dependencies: [
                "RimeKit", "KUMECore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            swiftSettings: strictSwift
        ),

        .testTarget(name: "RimeKitTests", dependencies: ["RimeKit"]),
        .testTarget(name: "KUMECoreTests", dependencies: ["KUMECore", "RimeKit"], exclude: ["Fixtures"]),
        .testTarget(name: "KUMEPanelTests", dependencies: ["KUMEPanel"]),
        .testTarget(name: "KUMEAITests", dependencies: ["KUMEAI"]),
    ]
)
