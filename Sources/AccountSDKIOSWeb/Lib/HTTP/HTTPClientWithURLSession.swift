import Foundation

class HTTPClientWithURLSession: HTTPClient {
    private let session: URLSessionProtocol

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func execute<T: Decodable>(request: URLRequest, withRetryPolicy: RetryPolicy, completion: @escaping HTTPResultHandler<T>) {
        func retry(_ attempts: Int) {
            execute(request: request) { (result: Result<T, HTTPError>) in
                switch result {
                case .success(_):
                    completion(result)
                case .failure(let error):
                    if attempts > 0 && withRetryPolicy.shouldRetry(for: error) {
                        SchibstedAccountLogger.instance.debug("HTTP client, retrying \(String(describing: request.url))")
                        retry(attempts - 1)
                    } else {
                        completion(result)
                    }
                }
            }
        }
        
        retry(withRetryPolicy.numRetries(for: request))
    }

    private func execute<T: Decodable>(request: URLRequest, completion: @escaping HTTPResultHandler<T>) {
        let requestUrlString = request.url?.absoluteString ?? "<nil>"
        let requestHeaders = request.allHTTPHeaderFields ?? [:]
        SchibstedAccountLogger.instance.info("Requesting \(requestUrlString) headers: \(requestHeaders)")

        let task = session.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            let httpCode = httpResponse?.statusCode ?? -1
            let responseHeaders = httpResponse?.allHeaderFields ?? [:]
            let jsonBody = data.flatMap { String(data: $0, encoding: .utf8) }
            SchibstedAccountLogger.instance.info("Response for: \(requestUrlString), code \(httpCode), headers: \(responseHeaders), bodyText: \(jsonBody ?? "<nil>")")

            if let requestError = error {
                SchibstedAccountLogger.instance.error("Request \(requestUrlString) failed, error: \(error.debugDescription)")
                completion(.failure(.unexpectedError(underlying: requestError)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.isError {
                let errorBody = data.map { String(decoding: $0, as: UTF8.self) }
                SchibstedAccountLogger.instance.error("Request \(requestUrlString) failed, error body \(errorBody ?? "")")
                completion(.failure(.errorResponse(code: httpResponse.statusCode, body: errorBody)))
                return
            }
            
            guard let responseBody = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let deserialised = try JSONDecoder().decode(T.self, from: responseBody)
                completion(.success(deserialised))
            } catch {
                completion(.failure(.unexpectedError(underlying: error)))
            }
        }
        
        task.resume()
    }
}
