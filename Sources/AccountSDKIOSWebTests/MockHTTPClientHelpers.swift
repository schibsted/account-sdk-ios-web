//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Cuckoo

@testable import AccountSDKIOSWeb

struct MockHTTPClientHelpers {
    let mockHTTPClient = MockHTTPClient()

    @MainActor
    func stubHTTPClientExecuteRefreshRequest(refreshResult: Result<TokenResponse, HTTPError>) {
        stub(mockHTTPClient) { mock in
            // refresh token request
            let closureMatcher: ParameterMatcher<HTTPResultHandler<TokenResponse>> = ParameterMatcher()
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: closureMatcher))
                .then { _, _, completion in
                    completion(refreshResult)
                }
        }
    }

    @MainActor
    func stubHTTPClientExecuteRequest(result: Result<TestResponse, HTTPError>) {
        stub(mockHTTPClient) { mock in
            // makeRequest on saveRequestOnRefreshSuccess
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: ParameterMatcher()))
                .then { (_, _, completion: HTTPResultHandler<TestResponse>) in
                    completion(result)
                }
        }
    }

    func stubSessionStorageStore(mockSessionStorage: MockSessionStorage, result: Result<Void, Error>) {
        stub(mockSessionStorage) { mock in
            when(mock.store(any(), accessGroup: any())).then { _ in
            }
        }
    }
}
