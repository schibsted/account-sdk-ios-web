//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import SwiftUI
import WebKit
import AccountSDKIOSWeb
import AuthenticationServices

struct ContentView: View {
    let client: Client
    let clientConfiguration: ClientConfiguration
    
    @State var userDelegate: MyUserDelegate?
    @State private var user: User? {
        didSet {
            let userDelegate = MyUserDelegate()
            userDelegate.onLogout = { print("Callback will be invoked when user is logged out") }
            user?.delegates.addDelegate(userDelegate)
            self.userDelegate = userDelegate // Needs to be retained
        }
    }
    var userIsLoggedIn: Bool {
        get {
            user?.isLoggedIn() ?? false
        }
    }
    
    @State private var accountPagesURL: URL?
    @State private var showAccountPages = false
    @State private var asWebAuthSession: ASWebAuthenticationSession?
    
    init(client: Client, clientConfiguration: ClientConfiguration) {
        self.client = client
        self.clientConfiguration = clientConfiguration
    }
    
    var body: some View {
        NavigationView {
            let webView = WebView(url: $accountPagesURL)
            
            VStack(spacing: 50) {
                VStack(spacing: 20) {
                    Group {
                        Text(String(describing: client))
                        Text("Logged-in as \(user?.uuid ?? "unknown")")
                    }
                    Button(action: resumeUser, label: { Text("Resume user")})
                    Button(action: login, label: { Text("Login") } )
                        .onOpenURL { url in
                            handleOnOpenUrl(url: url)
                        }
                    Button(action: trigger2faOtpFlow, label: { Text("Trigger 2FA (OTP)")})
                    Button(action: trigger2faSmsFlow, label: { Text("Trigger 2FA (SMS)")})
                    Button(action: triggerBankIdFlow, label: { Text("Trigger BankId for NO") })
                    Button(action: triggerSimplifiedLogin, label: { Text("Trigger Simplified login ")})
                }
                
                VStack(spacing: 20) {
                    Button(action: fetchProfileData, label: { Text("Fetch profile data") } )
                    Button(action: startSessionExchange, label: { Text("Start session exchange") } )
                    Button(action: openAccountPages, label: { Text("Show account pages") } )
                    Button(action: logout, label: { Text("Logout") } )
                    
                }.disabled(!userIsLoggedIn)
                
                NavigationLink("", destination: webView, isActive: $showAccountPages)
            }
        }
        
    }
    
    func triggerSimplifiedLogin() {
        let context = ASWebAuthSessionContextProvider()
        let manager = SimplifiedLoginManager(client: client, contextProvider: context, completion: handleResult)
        manager.requestSimplifiedLogin() { result in
            switch (result) {
            case .success():
                print("success: requestSimplifiedLogin")
            case .failure(SimplifiedLoginManager.SimplifiedLoginError.noLoggedInSessionInSharedKeychain):
                print("failure: noLoggedInSessionInSharedKeychain")
            case .failure(SimplifiedLoginManager.SimplifiedLoginError.noClientNameFound):
                print("failure: noClientNameFound")
            case .failure(HTTPError.unexpectedError(underlying: LoginStateError.notLoggedIn)):
                print("failure: User is not logged in")
            case .failure(let error):
                print("failure: \(error)")
            }
        }
    }
    
    func resumeUser() {
        client.resumeLastLoggedInUser() { user in
            guard let user = user else {
                print("User could not be resumed")
                return
            }
            self.user = user
            print("Resumed user")
        }
    }
    
    func trigger2faOtpFlow() {
        let context = ASWebAuthSessionContextProvider()
        let session = client.getLoginSession(contextProvider: context,
                                                  withMFA: .otp,
                                                  withSSO: true,
                                                  completion: { result in
            switch result {
            case .success(let user):
                print("Success - logged in as \(user.uuid ?? "")")
                self.user = user
            case .failure(let error):
                print(error)
            }
        })
        
        if let session = session {
            // This will trigger the web context asking the user to login
            asWebAuthSession = session
            asWebAuthSession?.start()
        }
    }
    
    func trigger2faSmsFlow() {
        let context = ASWebAuthSessionContextProvider()
        let session = client.getLoginSession(contextProvider: context,
                                                  withMFA: .sms,
                                                  withSSO: true) { result in
            switch result {
            case .success(let user):
                print("Success - logged in as \(user.uuid ?? "")")
                self.user = user
            case .failure(let error):
                print(error)
            }
        }
        if let session = session {
            asWebAuthSession = session
            asWebAuthSession?.start()
        }
    }
    
    func triggerBankIdFlow() {
        let context = ASWebAuthSessionContextProvider()
        let session = client.getLoginSession(contextProvider: context,
                                             withMFA: .preEid(.no),
                                                  withSSO: true) { result in
            switch result {
            case .success(let user):
                print("Success - logged in as \(user.uuid ?? "")")
                self.user = user
            case .failure(let error):
                print(error)
            }
        }
        if let session = session {
            asWebAuthSession = session
            asWebAuthSession?.start()
        }
    }
    
    func login() {
        let context = ASWebAuthSessionContextProvider()
        let session = client.getLoginSession(contextProvider: context,
                                                  withSSO: true,
                                                  completion: handleResult)
        if let session = session {
            asWebAuthSession = session
            asWebAuthSession?.start()
        }
    }
    
    func handleOnOpenUrl(url: URL) {
        if url.pathComponents.contains("bankId") {
            return
        }
        
        client.handleAuthenticationResponse(url: url) { result in
            DispatchQueue.main.async {
                asWebAuthSession?.cancel()
            }
            handleResult(result)
        }
    }
    
    func fetchProfileData() {
        self.user?.fetchProfileData { result in
            switch result {
            case .success(let userData):
                print(userData)
            case .failure(.unexpectedError(LoginStateError.notLoggedIn)):
                print("User was logged-out")
                self.user = nil
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func startSessionExchange() {
        self.user?.webSessionURL(clientId: "602504e1b41fa31789a95aa7", redirectURI: "http://zoopermarket.com/safepage") { result in
            switch result {
            case .success(let sessionUrl):
                print(sessionUrl)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func openAccountPages() {
        self.user?.webSessionURL(clientId: "602504e1b41fa31789a95aa7", redirectURI: self.clientConfiguration.accountPagesURL.absoluteString) { result in
            switch result {
            case .success(let sessionUrl):
                print(sessionUrl)
                accountPagesURL = sessionUrl
                showAccountPages = true
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func logout() {
        self.user?.logout()
        self.user = nil
        print("Logged out")
    }
    
    func handleResult(_ result: Result<User, LoginError>) {
        switch result {
        case .success(let user):
            print("Success - logged in as \(user.uuid ?? "")")
            self.user = user
        case .failure(let error):
            print(error)
        }
    }
}

struct WebView : UIViewRepresentable {
    @Binding var url: URL?
    
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let u = url {
            uiView.load(URLRequest(url: u))
        }
    }
}

class MyUserDelegate: UserDelegate {
    var onLogout: (() -> Void)?
    
    // MARK: UserDelegate
    
    func userDidLogout() {
        onLogout?()
    }
}
