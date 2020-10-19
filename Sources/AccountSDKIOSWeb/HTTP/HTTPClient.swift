import Foundation



public enum HTTPError: Error {
    case errorResponse(code: Int, body: String?)
    case unexpectedError(underlying: Error)
    case noData
}

public protocol HTTPClient {
    func get<T: Codable>(url: URL, completion: @escaping (Result<T, HTTPError>) -> Void)
    func post<T: Codable>(url: URL, body: Data, contentType: String, authorization: String?, completion: @escaping (Result<T, HTTPError>) -> Void)
}

public class HTTPClientWithURLSession: HTTPClient {
    private let session: URLSession

    public init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    public func get<T: Codable>(url: URL, completion: @escaping (Result<T, HTTPError>) -> Void) {
        execute(request: URLRequest(url: url), completion: completion)
    }

    public func post<T: Codable>(url: URL, body: Data, contentType: String, authorization: String?, completion: @escaping (Result<T, HTTPError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        authorization.map { request.setValue($0, forHTTPHeaderField: "Authorization") }

        execute(request: request, completion: completion)
    }
    
    private func execute<T: Codable>(request: URLRequest, completion: @escaping (Result<T, HTTPError>) -> Void) {
        let task = session.dataTask(with: request) { (data, response, error) in
            if let requestError = error {
                completion(.failure(.unexpectedError(underlying: requestError)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
                  !(200...299).contains(httpResponse.statusCode) { // TODO handle any other non-200 statuses?
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
