import Foundation

public class HTTPClientWithURLSession: HTTPClient {
    private let session: URLSessionProtocol

    public init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    public func execute<T: Decodable>(request: URLRequest, withRetryPolicy: RetryPolicy, completion: @escaping HTTPResultHandler<T>) {
        func retry(_ attempts: Int) {
            execute(request: request) { (result: Result<T, HTTPError>) in
                switch result {
                case .success(_):
                    completion(result)
                case .failure(let error):
                    if attempts > 0 && withRetryPolicy.shouldRetry(for: error) {
                        SchibstedAccountLogger.instance.debug("HTTP client, retrying \(request.url)")
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
        let task = session.dataTask(with: request) { (data, response, error) in
            if let requestError = error {
                completion(.failure(.unexpectedError(underlying: requestError)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
                  !(200...399).contains(httpResponse.statusCode) {
                let errorBody = data.map { String(decoding: $0, as: UTF8.self) }
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
