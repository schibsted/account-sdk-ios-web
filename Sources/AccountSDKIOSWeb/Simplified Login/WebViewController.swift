import WebKit

class WebViewController: UIViewController {
    
    private let webView: WKWebView
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let activityIndicatorView = UIActivityIndicatorView()
    
    private var estimatedProgressObserver: NSKeyValueObservation?
    
    init() {
        webView = WKWebView()
        webView.backgroundColor = .white
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        webView.navigationDelegate = self
        view = webView
        
        addLoadingViews()
        setupEstimatedProgressObserver()
    }
    
    func loadURL(_ url: URL) {
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: url))
        }
    }
    
    private func addLoadingViews() {
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.center = CGPoint(x: UIScreen.main.bounds.width/2,
                                               y: UIScreen.main.bounds.height/2)
        activityIndicatorView.style = .gray
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        guard let navigationBar = navigationController?.navigationBar else {
            return
        }
        progressView.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor),
            
            progressView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2.0)
        ])
    }
    
    private func setupEstimatedProgressObserver() {
        estimatedProgressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            self?.progressView.progress = Float(webView.estimatedProgress)
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if progressView.isHidden {
            progressView.isHidden = false
        }
        UIView.animate(withDuration: 0.33,
                       animations: {
            self.progressView.alpha = 1.0
        })
    }
    
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
        
        UIView.animate(withDuration: 0.33,
                       animations: {
            self.progressView.alpha = 0.0
        },
                       completion: { isFinished in
            self.progressView.isHidden = isFinished
        })
    }
}
