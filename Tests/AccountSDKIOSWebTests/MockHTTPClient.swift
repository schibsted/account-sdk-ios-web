import Foundation
@testable import AccountSDKIOSWeb

class MockHTTPClient<R: Codable>: HTTPClient {
    private let result: Result<R, HTTPError>

    init(withResult: R) {
        self.result = .success(withResult)
    }
    
    func post<T: Codable>(url: URL, body: Data, contentType: String, authorization: String?, completion: @escaping (Result<T, HTTPError>) -> Void) {
        completion(result as! Result<T, HTTPError>)
    }
}
