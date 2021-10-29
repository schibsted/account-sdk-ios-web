import Foundation

class URLSessionMock: URLSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    var data: Data?
    var error: Error?
    var errorResponse: URLResponse?
    var successResponse: URLResponse?
    var startWithFailure: Bool = false
    
    override func dataTask(
        with request: URLRequest,
        completionHandler: @escaping CompletionHandler
    ) -> URLSessionDataTask {
        let data = self.data
        let error = self.error
        var response = successResponse
        
        if startWithFailure {
            response = errorResponse
            startWithFailure = false
        }
        
        return URLSessionDataTaskMock {
            completionHandler(data, response, error)
        }
    }
}

class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    override func resume() {
        closure()
    }
}
