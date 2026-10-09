import Foundation
import Testing
import KUMECore
@testable import KUMEAI

@Suite(.serialized)
struct CustomProviderTests {
    @Test(arguments: ["https://provider.example/v1", "https://provider.example/v1/",
                      "https://provider.example/v1/chat/completions"])
    func requestsUsePersistedSettings(_ address: String) async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("kume-provider-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root); ProviderProtocol.handler = nil }
        let paths = KUMEPaths(userDataDir: root.appendingPathComponent("Rime"))
        var features = KUMEFeatures()
        features.aiBaseURL = address
        features.aiModel = "custom-model"
        try features.save(paths)
        let credentials = CredentialStore(account: "openai-compatible", fileURL: root.appendingPathComponent("credentials.json"))
        #expect(credentials.write("test-only-key"))

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [ProviderProtocol.self]
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }
        ProviderProtocol.handler = { request in
            #expect(request.url?.absoluteString == "https://provider.example/v1/chat/completions")
            #expect(request.httpMethod == "POST")
            #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer test-only-key")
            let body = try #require(try JSONSerialization.jsonObject(with: ProviderProtocol.body(request)) as? [String: Any])
            #expect(body["model"] as? String == "custom-model")
            let messages = try #require(body["messages"] as? [[String: String]])
            #expect(messages == [["role": "system", "content": "test instructions"], ["role": "user", "content": "synthetic text"]])
            return Data(#"{"choices":[{"message":{"content":"custom provider reply"}}]}"#.utf8)
        }
        let provider = try OpenAICompatibleProvider(configuration: KUMEFeatures.load(paths), credentials: credentials, session: session)
        #expect(await provider.availability() == .available)
        #expect(try await provider.complete(instructions: "test instructions", prompt: "synthetic text") == "custom provider reply")
    }

    @Test(arguments: ["", "not a URL", "file:///tmp/model", "https:///v1", "httpx://example.com",
                      "https://user:password@example.com/v1", "https://example.com/v1?key=secret",
                      "https://example.com/v1#fragment"])
    func invalidAddressesDoNotCreateAProvider(_ address: String) {
        var features = KUMEFeatures()
        features.aiBaseURL = address
        features.aiModel = "test-model"
        #expect(throws: AIError.self) { try OpenAICompatibleProvider(configuration: features) }
    }

    @Test func configurationIsRequiredAndLocalEndpointsAreSupported() throws {
        #expect(throws: AIError.self) { try OpenAICompatibleProvider(configuration: KUMEFeatures()) }
        var features = KUMEFeatures()
        features.aiBaseURL = " http://localhost:1234/v1 \n"
        features.aiModel = "  "
        #expect(throws: AIError.self) { try OpenAICompatibleProvider(configuration: features) }
        features.aiModel = " local-model \n"
        let provider = try OpenAICompatibleProvider(configuration: features)
        #expect(provider.baseURL.absoluteString == "http://localhost:1234/v1")
        #expect(provider.model == "local-model")
    }

    @Test func oldProviderSelectionCannotOverrideTheSavedEndpoint() throws {
        let data = Data(#"{"aiProvider":"apple","aiBaseURL":"https://provider.example/v1","aiModel":"saved-model"}"#.utf8)
        let features = try JSONDecoder().decode(KUMEFeatures.self, from: data)
        let provider = try OpenAICompatibleProvider(configuration: features)
        #expect(provider.id == "openai-compatible")
        #expect(provider.model == "saved-model")
        #expect(!features.aiRemoteAllowed)
    }
}

private final class ProviderProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> Data)?
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        do {
            let data = try Self.handler!(request)
            client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: 200,
                                                                httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch { client?.urlProtocol(self, didFailWithError: error) }
    }
    override func stopLoading() {}

    static func body(_ request: URLRequest) throws -> Data {
        if let data = request.httpBody { return data }
        let stream = try #require(request.httpBodyStream)
        stream.open()
        defer { stream.close() }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        while true {
            let count = stream.read(&buffer, maxLength: buffer.count)
            guard count > 0 else { break }
            data.append(contentsOf: buffer.prefix(count))
        }
        return data
    }
}
