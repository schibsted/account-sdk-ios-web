import Foundation

typealias SimplifiedLoginFetchedData = (context: UserContextFromTokenResponse, profile: UserProfileResponse)

protocol SimplifiedLoginDataFetching {
    func fetch(completion: @escaping (Result<SimplifiedLoginFetchedData, Error>) -> Void)
}

struct SimplifiedLoginDataFetcher: SimplifiedLoginDataFetching {
    let user: User
    
    func fetch(completion: @escaping (Result<SimplifiedLoginFetchedData, Error>) -> Void) {
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
}
