import XCTest
@testable import ModernNetworking

final class ModernNetworkingTests: XCTestCase {
    func testApplyEnvironmentLoaderAppliesEnvironmentValues() async {
        let environment = ServerEnvironment(
            scheme: "https",
            host: "api.example.com",
            pathPrefix: "/v1",
            headers: ["X-Env": "prod"],
            query: [URLQueryItem(name: "locale", value: "en")]
        )

        let recorder = RequestRecorder()
        let terminal = RecordingTerminalLoader(recorder: recorder, result: .success(makeResponse(for: makeRequest(path: "/ok"))))

        let loader = ApplyEnvironmentLoader(environment: environment)
        loader.nextLoader = terminal

        var request = HTTPRequest(path: "todos", headers: ["X-Client": "ios"])
        request.scheme = "http"

        let result = await loader.load(request)
        XCTAssertNotNil(result.response)

        let captured = await recorder.lastRequest()
        XCTAssertEqual(captured?.scheme, "https")
        XCTAssertEqual(captured?.host, "api.example.com")
        XCTAssertEqual(captured?.path, "/v1/todos")
        XCTAssertEqual(captured?.headers["X-Client"], "ios")
        XCTAssertEqual(captured?.headers["X-Env"], "prod")
        XCTAssertEqual(captured?.queryItems.last, URLQueryItem(name: "locale", value: "en"))
    }

    func testEntityTagLoaderReusesTagForSubsequentRequests() async {
        let cache = InMemoryEntityTagCache()
        let recorder = RequestRecorder()

        let firstResponse = makeResponse(
            for: makeRequest(path: "/todos"),
            statusCode: 200,
            headers: ["ETag": "W/\"abc\""],
            body: Data("{\"ok\":true}".utf8)
        )

        let secondResponse = makeResponse(
            for: makeRequest(path: "/todos"),
            statusCode: 304
        )

        let terminal = SequencedTerminalLoader(
            recorder: recorder,
            responses: [.success(firstResponse), .success(secondResponse)]
        )

        let loader = EntityTagLoader(cache: cache)
        loader.nextLoader = terminal

        let request = makeRequest(path: "/todos")
        _ = await loader.load(request)
        _ = await loader.load(request)

        let requests = await recorder.requests()
        XCTAssertEqual(requests.count, 2)
        XCTAssertNil(requests[0].headers["If-None-Match"])
        XCTAssertEqual(requests[1].headers["If-None-Match"], "W/\"abc\"")
    }

    func testResetGuardLoaderRejectsLoadsWhileResetting() async {
        let resettable = ControlledResetLoader()
        let guardLoader = ResetGuardLoader()
        guardLoader.nextLoader = resettable

        let blockedResultStore = ResultStore()
        let request = makeRequest(path: "/todos")

        resettable.onResetStart = {
            let blockedResult = await guardLoader.load(request)
            await blockedResultStore.store(blockedResult)
        }

        await guardLoader.reset()

        let blockedResult = await blockedResultStore.last()
        XCTAssertEqual(blockedResult.error?.code, .resetInProgress)

        let nextResult = await guardLoader.load(request)
        XCTAssertNotNil(nextResult.response)
    }

    func testURLSessionLoaderBuildsURLRequestAndReturnsResponse() async {
        let session = StubSession { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.value(forHTTPHeaderField: "X-Trace"), "123")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json; charset=utf-8")
            XCTAssertNotNil(request.httpBody)

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 201,
                httpVersion: "1.1",
                headerFields: ["X-Server": "stub"]
            )!

            return (Data("{\"created\":true}".utf8), response)
        }

        let loader = URLSessionLoader(session: session)
        struct Payload: Codable, Sendable { let id: Int }

        let request = HTTPRequest(
            method: .post,
            path: "/todos",
            body: JSONBody(Payload(id: 7)),
            headers: ["X-Trace": "123"]
        )
        .withHost("api.example.com")

        let result = await loader.load(request)
        XCTAssertEqual(result.response?.statusCode, .created)
        XCTAssertEqual(result.response?.headers["X-Server"] as? String, "stub")
    }

    func testURLSessionLoaderMapsCancellationErrors() async {
        let session = StubSession { _ in
            throw URLError(.cancelled)
        }

        let loader = URLSessionLoader(session: session)
        let result = await loader.load(makeRequest(path: "/todos"))
        XCTAssertEqual(result.error?.code, .cancelled)
    }

    func testDecodingExtensionDecodesModelWithAsyncAwait() async throws {
        struct Todo: Model, Equatable {
            let id: Int
            let title: String
        }

        let body = Data("{\"id\":1,\"title\":\"Ship async API\"}".utf8)
        let response = makeResponse(for: makeRequest(path: "/todos/1"), body: body)

        let value = try await HTTPResult.success(response).decoding(Todo.self)
        XCTAssertEqual(value, Todo(id: 1, title: "Ship async API"))
    }

    func testSequentialMockLoaderConsumesHandlersInOrder() async {
        let loader = SequentialMockLoader()
        loader.then { request in
            .success(self.makeResponse(for: request, statusCode: 200))
        }
        loader.then { request in
            .success(self.makeResponse(for: request, statusCode: 201))
        }

        let request = makeRequest(path: "/sequence")

        let first = await loader.load(request)
        let second = await loader.load(request)
        let third = await loader.load(request)

        XCTAssertEqual(first.response?.statusCode, .ok)
        XCTAssertEqual(second.response?.statusCode, .created)
        XCTAssertEqual(third.error?.code, .cannotConnect)
    }

    private func makeRequest(path: String) -> HTTPRequest {
        var request = HTTPRequest(path: path)
        request.host = "api.example.com"
        return request
    }

    private func makeResponse(
        for request: HTTPRequest,
        statusCode: Int = 200,
        headers: [String: String] = [:],
        body: Data? = nil
    ) -> HTTPResponse {
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: "1.1",
            headerFields: headers
        )!
        return HTTPResponse(request, response, body)
    }
}

private extension HTTPRequest {
    func withHost(_ host: String) -> HTTPRequest {
        var copy = self
        copy.host = host
        return copy
    }
}

private actor RequestRecorder {
    private var capturedRequests: [HTTPRequest] = []

    func record(_ request: HTTPRequest) {
        capturedRequests.append(request)
    }

    func requests() -> [HTTPRequest] {
        capturedRequests
    }

    func lastRequest() -> HTTPRequest? {
        capturedRequests.last
    }
}

private final class RecordingTerminalLoader: HTTPLoader {
    private let recorder: RequestRecorder
    private let result: HTTPResult

    init(recorder: RequestRecorder, result: HTTPResult) {
        self.recorder = recorder
        self.result = result
        super.init()
    }

    override func load(_ request: HTTPRequest) async -> HTTPResult {
        await recorder.record(request)
        return result
    }
}

private final class SequencedTerminalLoader: HTTPLoader {
    private let recorder: RequestRecorder
    private var remaining: [HTTPResult]

    init(recorder: RequestRecorder, responses: [HTTPResult]) {
        self.recorder = recorder
        self.remaining = responses
        super.init()
    }

    override func load(_ request: HTTPRequest) async -> HTTPResult {
        await recorder.record(request)
        guard remaining.isEmpty == false else {
            return .failure(HTTPError(.cannotConnect, request))
        }

        return remaining.removeFirst()
    }
}

private actor InMemoryEntityTagCache: EntityTagCaching {
    private var tags: [String: String] = [:]

    func store(entityTag: String, for url: URL) async {
        tags[url.absoluteString] = entityTag
    }

    func loadEntityTag(for url: URL) async -> String? {
        tags[url.absoluteString]
    }
}

private final class ControlledResetLoader: HTTPLoader {
    var onResetStart: (() async -> Void)?

    override func reset() async {
        await onResetStart?()
    }

    override func load(_ request: HTTPRequest) async -> HTTPResult {
        .success(HTTPResponse(request, HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: "1.1",
            headerFields: [:]
        )!))
    }
}

private actor ResultStore {
    private var result: HTTPResult?

    func store(_ result: HTTPResult) {
        self.result = result
    }

    func last() -> HTTPResult {
        result ?? .failure(HTTPError(.unknown, HTTPRequest(path: "/missing")))
    }
}

private actor StubSession: URLSessioning {
    private let handler: @Sendable (URLRequest) async throws -> (Data, URLResponse)

    init(handler: @escaping @Sendable (URLRequest) async throws -> (Data, URLResponse)) {
        self.handler = handler
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await handler(request)
    }
}
