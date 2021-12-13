import Foundation

typealias SimplifiedLoginFetchedData = (context: UserContextFromTokenResponse, profile: UserProfileResponse)
typealias SimplifiedLoginAssertionResult = Result<SimplifiedLoginAssertionResponse, Error>

protocol SimplifiedLoginFetching {
    func fetchData(completion: @escaping (Result<SimplifiedLoginFetchedData, Error>) -> Void)
    func fetchAssertion(completion: @escaping (Result<SimplifiedLoginAssertionResponse, Error>) -> Void)
}

struct SimplifiedLoginFetcher: SimplifiedLoginFetching {
    let user: User
    
    func fetchData(completion: @escaping (Result<SimplifiedLoginFetchedData, Error>) -> Void) {
        user.userContextFromToken { result in
            switch result {
            case .success(let userContextResponse):
                self.fetchProfile(userContext: userContextResponse, completion: completion)
            case .failure(let error):
                SchibstedAccountLogger.instance.error("Failed to fetch userContextFromToken: \(String(describing: error))")
                completion(.failure(error))
            }
        }
    }
    
    func fetchProfile(userContext: UserContextFromTokenResponse, completion: @escaping (Result<SimplifiedLoginFetchedData, Error>) -> Void) {
        user.fetchProfileData { result in
            switch result {
            case .success(let profileResponse):
                completion(.success((userContext, profileResponse)))
            case .failure(let error):
                SchibstedAccountLogger.instance.error("Failed to fetch profileData: \(String(describing: error))")
                completion(.failure(error))
            }
        }
    }
    
    func fetchAssertion(completion: @escaping (SimplifiedLoginAssertionResult) -> Void) {
        user.assertionForSimplifiedLogin { result in
            switch result {
            case .success(let assertionResponse):
                completion(.success(assertionResponse))
            case .failure(let error):
                SchibstedAccountLogger.instance.error("Failed to fetch Simplified Login assertion: \(String(describing: error))")
                completion(.failure(error))
            }
        }
    }
}
