import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    let webView: WKWebView
    
    override func loadView() {
        webView.navigationDelegate = self
        view = webView
    }
    
    init(url: URL) {
        webView = WKWebView()
        webView.load(URLRequest(url: url))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
