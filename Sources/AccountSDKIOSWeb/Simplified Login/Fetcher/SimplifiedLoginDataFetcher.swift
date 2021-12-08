import Foundation

typealias SimplifiedLoginFetchedData = (context: UserContextFromTokenResponse, profile: UserProfileResponse, visibleClientName: String?)

protocol SimplifiedLoginDataFetching {
    func fetch(_ visibleClientName: String?, completion: @escaping (Result<SimplifiedLoginFetchedData, Error>) -> Void)
}

struct SimplifiedLoginDataFetcher: SimplifiedLoginDataFetching {
    let user: User
    
    func fetch(_ visibleClientName: String? = nil, completion: @escaping (Result<SimplifiedLoginFetchedData, Error>) -> Void) {
        user.userContextFromToken { result in
            switch result {
            case .success(let userContextResponse):
                self.fetchProfile(visibleClientName, userContext: userContextResponse, completion: completion)
            case .failure(let error):
                SchibstedAccountLogger.instance.error("Failed to fetch userContextFromToken: \(String(describing: error))")
                completion(.failure(error))
            }
        }
    }
    
    func fetchProfile(_ visibleClientName: String?, userContext: UserContextFromTokenResponse, completion: @escaping (Result<SimplifiedLoginFetchedData, Error>) -> Void) {
        user.fetchProfileData { result in
            switch result {
            case .success(let profileResponse):
                completion(.success((userContext, profileResponse, visibleClientName)))
            case .failure(let error):
                SchibstedAccountLogger.instance.error("Failed to fetch profileData: \(String(describing: error))")
                completion(.failure(error))
            }
        }
    }
}
