//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

final class HTTPClientWithURLSession: HTTPClient {
    private let session: URLSessionProtocol

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    @MainActor
    func execute<T: Decodable>(request: URLRequest, withRetryPolicy: RetryPolicy, completion: @escaping HTTPResultHandler<T>) {
        func retry(_ attempts: Int) {
            execute(request: request) { (result: Result<T, HTTPError>) in
                switch result {
                case .success:
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

    @MainActor
    private func execute<T: Decodable>(request: URLRequest, completion: @escaping HTTPResultHandler<T>) {
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let requestError = error {
                    completion(.failure(.unexpectedError(underlying: requestError)))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.isError {
                    let errorBody = data.map { String(decoding: $0, as: UTF8.self) }
                    completion(.failure(.errorResponse(code: httpResponse.statusCode, body: errorBody)))
                    return
                }
                
                guard let responseBody = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let deserialised = try decoder.decode(T.self, from: responseBody)
                    completion(.success(deserialised))
                } catch {
                    completion(.failure(.unexpectedError(underlying: error)))
                }
            }
        }

        task.resume()
    }
}
