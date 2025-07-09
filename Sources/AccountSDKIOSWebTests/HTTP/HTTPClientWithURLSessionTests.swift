//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest

@testable import AccountSDKIOSWeb

private final class TestRetryPolicy: RetryPolicy {
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
    @MainActor
    func testDoesntRetrySuccessfulRequest() throws {
        let request = URLRequest(url: URL(staticString: "https://example.com"))
        let expectedResponse = TestResponse(data: "Hello world!")
        
        let urlResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)
        let result: (Data?, HTTPURLResponse?, Error?) = (try JSONEncoder().encode(expectedResponse), urlResponse, nil)
        let sessionMock = MockURLSessionProtocol(request: request, results: [result])
        HTTPClientWithURLSession(session: sessionMock).execute(request: request, withRetryPolicy: TestRetryPolicy.policy) { (result: Result<TestResponse, HTTPError>) in
            switch result {
            case .success(let receviedResponse):
                XCTAssertEqual(receviedResponse, expectedResponse)
            case .failure(_):
                XCTFail("Unexpected request failure")
            }
        }
        
        // only 1 request, no retry
        XCTAssertTrue(sessionMock.counter == 1)
    }

    @MainActor
    func testRetriesFailedRequest() throws {
        let request = URLRequest(url: URL(staticString: "https://example.com"))
        let expectedResponse = TestResponse(data: "Hello world!")
        
        let failedRequestResult: (Data?, HTTPURLResponse?, Error?) = (nil, nil, URLError(.cannotConnectToHost))
        let urlResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)
        let successRequestResult: (Data?, HTTPURLResponse?, Error?) = (try JSONEncoder().encode(expectedResponse), urlResponse, nil)

        let expectation = self.expectation(description: "requests")
        let sessionMock = MockURLSessionProtocol(request: request, results: [failedRequestResult, successRequestResult])
        HTTPClientWithURLSession(session: sessionMock).execute(request: request, withRetryPolicy: TestRetryPolicy.policy) { (result: Result<TestResponse, HTTPError>) in
            switch result {
            case .success(let receviedResponse):
                XCTAssertEqual(receviedResponse, expectedResponse)
                expectation.fulfill()
            case .failure(_):
                XCTFail("Unexpected request failure")
            }
        }
        
        // 2 requests: initial + 1 retry
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sessionMock.counter, 2)
    }

    @MainActor
    func testRetries5xxRequest() throws {
        let request = URLRequest(url: URL(staticString: "https://example.com"))
        let expectedResponse = TestResponse(data: "Hello world!")
        
        let failedUrlResponse = HTTPURLResponse(url: request.url!, statusCode: 502, httpVersion: "HTTP/1.1", headerFields: nil)
        let failedRequestResult: (Data?, HTTPURLResponse?, Error?) = ("Something went wrong".data(using: .utf8), failedUrlResponse, nil)
        let successUrlResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)
        let successRequestResult: (Data?, HTTPURLResponse?, Error?) = (try JSONEncoder().encode(expectedResponse), successUrlResponse, nil)

        let expectation = self.expectation(description: "requests")
        let sessionMock = MockURLSessionProtocol(request: request, results: [failedRequestResult, successRequestResult])
        HTTPClientWithURLSession(session: sessionMock).execute(request: request, withRetryPolicy: TestRetryPolicy.policy) { (result: Result<TestResponse, HTTPError>) in
            switch result {
            case .success(let receviedResponse):
                XCTAssertEqual(receviedResponse, expectedResponse)
                expectation.fulfill()
            case .failure(_):
                XCTFail("Unexpected request failure")
            }
        }
        
        // 2 requests: initial + 1 retry
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sessionMock.counter, 2)
    }

    @MainActor
    func testDontRetryFailedRequestIfNoRetriesPolicy() throws {
        let request = URLRequest(url: URL(staticString: "https://example.com"))
        
        let failureResults: [(Data?, HTTPURLResponse?, Error?)] = [
            (nil, nil, URLError(.cannotConnectToHost)),
            ("Something went wrong".data(using: .utf8), HTTPURLResponse(url: request.url!, statusCode: 502, httpVersion: "HTTP/1.1", headerFields: nil), nil),
        ]
        
        for failedResult in failureResults {
            let sessionMock = MockURLSessionProtocol(request: request, results: [failedResult])
            HTTPClientWithURLSession(session: sessionMock).execute(request: request, withRetryPolicy: NoRetries.policy) { (result: Result<TestResponse, HTTPError>) in
                if case .success = result {
                    XCTFail("Unexpected success response")
                }
            }
            
            // only 1 request, no retry
            XCTAssertEqual(sessionMock.counter, 1)
        }
    }
}
