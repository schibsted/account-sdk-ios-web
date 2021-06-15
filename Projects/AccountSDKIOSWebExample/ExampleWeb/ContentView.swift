import SwiftUI
import WebKit
import AccountSDKIOSWeb
import AuthenticationServices

struct ContentView: View {
    let client: Client
    private let clientID: String
    private let clientScheme: String

    @State private var user: User?
    var userIsLoggedIn: Bool {
        get {
            user?.isLoggedIn() ?? false
        }
    }

    @State private var accountPagesURL: URL?
    @State private var showAccountPages = false

    @State private var asWebAuthSession: ASWebAuthenticationSession?

    init(client: Client, clientID: String, clientRedirectURIScheme: String?) {
        self.client = client
        self.clientID = clientID
        self.clientScheme = clientRedirectURIScheme!
    }

    var body: some View {
        NavigationView {
            let webView = WebView(url: $accountPagesURL)

            VStack(spacing: 20) {
                Group {
                    Text("Client: \(clientID)")
                    Text("Logged-in as \(user?.uuid ?? "unknown")")
                }
                
                Button(action: {
                    guard let user = client.resumeLastLoggedInUser() else {
                        print("User could not be resumed")
                        return
                    }
                    self.user = user
                    print("Resumed user")
                }) {
                    Text("Resume user")
                }

                Group {
                    Button(action: {
                        let context = ASWebAuthSessionContextProvider()
                        asWebAuthSession = client.getLoginSession(contextProvider: context,
                                                                  withMFA: .otp,
                                                                  withSSO: true,
                                                                  completion: { result in
                            switch result {
                            case .success(let user):
                                print("Success - logged in as \(String(describing: user.uuid))")
                                self.user = user
                            case .failure(let error):
                                print(error)
                            }
                        })
                        
                        // This will trigger the web context asking the user to login
                        asWebAuthSession?.start()
       
                    }) {
                        Text("Trigger 2FA (OTP)")
                    }
                    
                    Button(action: {
                        
                        let context = ASWebAuthSessionContextProvider()
                        asWebAuthSession = client.getLoginSession(contextProvider: context,
                                                                  withMFA: .sms,
                                                                  withSSO: true) { result in
                            switch result {
                            case .success(let user):
                                print("Success - logged in as \(String(describing: user.uuid))!")
                                self.user = user
                            case .failure(let error):
                                print(error)
                            }
                        }
                        asWebAuthSession?.start()
                        
                    }) {
                        Text("Trigger 2FA (SMS)")
                    }
                }

                let loginButton = Button(action: {
                    let context = ASWebAuthSessionContextProvider()
                    asWebAuthSession = client.getLoginSession(contextProvider: context,
                                                              withSSO: true,
                                                              completion: handleResult)
                    asWebAuthSession?.start()
                }) {
                    Text("Login")
                }

                loginButton.onOpenURL { url in
                    client.handleAuthenticationResponse(url: url) { result in
                        DispatchQueue.main.async {
                            asWebAuthSession?.cancel()
                        }

                        handleResult(result)
                    }
                }
               
                Spacer().frame(height: 50)
                
                Button(action: {
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
                }) {
                    Text("Fetch profile data")
                }.disabled(!userIsLoggedIn)
                
                Button(action: {
                    self.user?.webSessionURL(clientId: "5bcdd51bfba0cc7427315112", redirectURI: "http://zoopermarket.com/safepage") { result in
                        switch result {
                        case .success(let sessionUrl):
                            print(sessionUrl)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }) {
                    Text("Start session exchange")
                }.disabled(!userIsLoggedIn)

                Button(action: {
                    if let url = self.user?.accountPagesURL() {
                        accountPagesURL = url
                        showAccountPages = true
                    }
                }) {
                    Text("Show account pages")
                }.disabled(!userIsLoggedIn)
                
                Button(action: {
                    self.user?.logout()
                    self.user = nil
                    print("Logged out")
                }) {
                    Text("Logout")
                }.disabled(!userIsLoggedIn)
                NavigationLink("", destination: webView, isActive: $showAccountPages)
            }
        }
    }
    
    func handleResult(_ result: Result<User, LoginError>) {
        switch result {
        case .success(let user):
            print("Success - logged in as \(String(describing: user.uuid)) - \(user.userId)!")
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
