import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

private class FakeDataTask: URLSessionDataTask {
    private let completionHandler: () -> Void

    init(completionHandler: @escaping () -> Void) {
        self.completionHandler = completionHandler
    }
    override func resume() {
        completionHandler()
    }
}

private class TestRetryPolicy: RetryPolicy {
    private init() {}
    
    public static let policy: TestRetryPolicy = TestRetryPolicy()
    
    func shouldRetry(for error: HTTPError) -> Bool {
        return true
    }
    
    func numRetries(for: URLRequest) -> Int {
        return 1
    }
}

final class HTTPClientWithURLSessionTests: XCTestCase {
    private func urlSessionMock(request: URLRequest, results: (response: Data?, urlResponse: HTTPURLResponse?, error: Error?) ...) -> MockURLSessionProtocol {
        let sessionMock = MockURLSessionProtocol()
        stub(sessionMock) { mock in
            var mock = when(mock.dataTask(with: equal(to: request), completionHandler: anyClosure()))
            for r in results {
                mock = mock.then {_, completionHandler in
                        return FakeDataTask {
                            completionHandler(r.response, r.urlResponse, r.error)
                        }
                    }
            }
        }
        
        return sessionMock
    }
    
    func testDoesntRetrySuccessfulRequest() throws {
        let request = URLRequest(url: URL("https://example.com"))
        let expectedResponse = TestResponse(data: "Hello world!")

        let urlResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)
        let result: (Data?, HTTPURLResponse?, Error?) = (try JSONEncoder().encode(expectedResponse), urlResponse, nil)
        let sessionMock = urlSessionMock(request: request, results: result)
        HTTPClientWithURLSession(session: sessionMock).execute(request: request, withRetryPolicy: TestRetryPolicy.policy) { (result: Result<TestResponse, HTTPError>) in
            switch result {
            case .success(let receviedResponse):
                XCTAssertEqual(receviedResponse, expectedResponse)
            case .failure(_):
                XCTFail("Unexpected request failure")
            }
        }
        
        // only 1 request, no retry
        verify(sessionMock, times(1)).dataTask(with: any(), completionHandler: any())
    }

    func testRetriesFailedRequest() throws {
        let request = URLRequest(url: URL("https://example.com"))
        let expectedResponse = TestResponse(data: "Hello world!")

        let failedRequestResult: (Data?, HTTPURLResponse?, Error?) = (nil, nil, URLError(.cannotConnectToHost))
        let urlResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)
        let successRequestResult: (Data?, HTTPURLResponse?, Error?) = (try JSONEncoder().encode(expectedResponse), urlResponse, nil)
        
        let sessionMock = urlSessionMock(request: request, results: failedRequestResult, successRequestResult)
        HTTPClientWithURLSession(session: sessionMock).execute(request: request, withRetryPolicy: TestRetryPolicy.policy) { (result: Result<TestResponse, HTTPError>) in
            switch result {
            case .success(let receviedResponse):
                XCTAssertEqual(receviedResponse, expectedResponse)
            case .failure(_):
                XCTFail("Unexpected request failure")
            }
        }
        
        // 2 requests: initial + 1 retry
        verify(sessionMock, times(2)).dataTask(with: any(), completionHandler: any())
    }
    
    func testRetries5xxRequest() throws {
        let request = URLRequest(url: URL("https://example.com"))
        let expectedResponse = TestResponse(data: "Hello world!")

        let failedUrlResponse = HTTPURLResponse(url: request.url!, statusCode: 502, httpVersion: "HTTP/1.1", headerFields: nil)
        let failedRequestResult: (Data?, HTTPURLResponse?, Error?) = ("Something went wrong".data(using: .utf8), failedUrlResponse, nil)
        let successUrlResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)
        let successRequestResult: (Data?, HTTPURLResponse?, Error?) = (try JSONEncoder().encode(expectedResponse), successUrlResponse, nil)
        
        let sessionMock = urlSessionMock(request: request, results: failedRequestResult, successRequestResult)
        HTTPClientWithURLSession(session: sessionMock).execute(request: request, withRetryPolicy: TestRetryPolicy.policy) { (result: Result<TestResponse, HTTPError>) in
            switch result {
            case .success(let receviedResponse):
                XCTAssertEqual(receviedResponse, expectedResponse)
            case .failure(_):
                XCTFail("Unexpected request failure")
            }
        }
        
        // 2 requests: initial + 1 retry
        verify(sessionMock, times(2)).dataTask(with: any(), completionHandler: any())
    }
    
    func testDontRetryFailedRequestIfNoRetriesPolicy() throws {
        let request = URLRequest(url: URL("https://example.com"))

        let failureResults: [(Data?, HTTPURLResponse?, Error?)] = [
            (nil, nil, URLError(.cannotConnectToHost)),
            ("Something went wrong".data(using: .utf8), HTTPURLResponse(url: request.url!, statusCode: 502, httpVersion: "HTTP/1.1", headerFields: nil), nil),
        ]

        for failedResult in failureResults {
            let sessionMock = urlSessionMock(request: request, results: failedResult)
            HTTPClientWithURLSession(session: sessionMock).execute(request: request, withRetryPolicy: NoRetries.policy) { (result: Result<TestResponse, HTTPError>) in
                if case .success = result {
                    XCTFail("Unexpected success response")
                }
            }

            // only 1 request, no retry
            verify(sessionMock, times(1)).dataTask(with: any(), completionHandler: any())
        }
    }
}
