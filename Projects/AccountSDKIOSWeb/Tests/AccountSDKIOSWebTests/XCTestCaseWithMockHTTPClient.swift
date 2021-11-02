import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

class XCTestCaseWithMockHTTPClient: XCTestCase {
    
    var mockHTTPClient: MockHTTPClient?
    
    override func setUp() {
        mockHTTPClient = MockHTTPClient()
    }
    
    // MARK: Helper mocking methods
    
    func stubHTTPClientExecuteRefreshRequest(mockHTTPClient: MockHTTPClient, refreshResult: Result<TokenResponse, HTTPError>) {
        stub(mockHTTPClient) { mock in
            // refresh token request
            let closureMatcher: ParameterMatcher<HTTPResultHandler<TokenResponse>> = anyClosure()
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: closureMatcher))
                .then { _, _, completion in
                    completion(refreshResult)
                }
        }
    }
    
    func stubHTTPClientExecuteRequest(mockHTTPClient: MockHTTPClient, result: Result<TestResponse, HTTPError>) {
        stub(mockHTTPClient) { mock in
            // makeRequest on saveRequestOnRefreshSuccess
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { (_, _, completion: HTTPResultHandler<TestResponse>) in
                    completion(result)
                }
        }
    }
    
    func stubSessionStorageStore(mockSessionStorage: MockSessionStorage, result: Result<Void, Error>) {
        stub(mockSessionStorage) { mock in
            when(mock.store(any(), completion: anyClosure())).then { _, completion in
                completion(result)
            }
        }
    }
}
