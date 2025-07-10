//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

typealias SimplifiedLoginFetchedData = (context: UserContextFromTokenResponse, profile: UserProfileResponse)
typealias SimplifiedLoginAssertionResult = Result<SimplifiedLoginAssertionResponse, Error>

protocol SimplifiedLoginFetching {
    @MainActor
    func fetchData(completion: @escaping (Result<SimplifiedLoginFetchedData, Error>) -> Void)
    @MainActor
    func fetchAssertion(completion: @escaping (Result<SimplifiedLoginAssertionResponse, Error>) -> Void)
}

@MainActor
final class SimplifiedLoginFetcher: SimplifiedLoginFetching {
    let client: Client
    init(client: Client) {
        self.client = client
    }

    var retainedSharedUser: User?

    func getLatestSharedUser() throws -> User {
        guard let latestUserSession = client.getLatestSharedSession() else {
            throw SimplifiedLoginManager.SimplifiedLoginError.noLoggedInSessionInSharedKeychain
        }
        let user = User(client: client, tokens: latestUserSession.userTokens)
        return user
    }

    func fetchData(completion: @escaping (Result<SimplifiedLoginFetchedData, Error>) -> Void) {
        do {
            let user = try getLatestSharedUser()
            self.retainedSharedUser = user
            user.userContextFromToken { result in
                switch result {
                case .success(let userContextResponse):
                    self.fetchProfile(user: user, userContext: userContextResponse, completion: completion)
                case .failure(let error):
                    SchibstedAccountLogger.instance
                        .error("Failed to fetch userContextFromToken: \(String(describing: error))")
                    completion(.failure(error))
                }
            }
        } catch {completion(.failure(error))}
    }

    func fetchProfile(user: User,
                      userContext: UserContextFromTokenResponse,
                      completion: @escaping (Result<SimplifiedLoginFetchedData, Error>) -> Void) {
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
        guard let user = retainedSharedUser else {
            completion(.failure(SimplifiedLoginManager.SimplifiedLoginError.noLoggedInSessionInSharedKeychain))
            return
        }

        user.assertionForSimplifiedLogin { result in
            switch result {
            case .success(let assertionResponse):
                completion(.success(assertionResponse))
            case .failure(let error):
                SchibstedAccountLogger.instance
                    .error("Failed to fetch Simplified Login assertion: \(String(describing: error))")
                completion(.failure(error))
            }
        }
    }
}
