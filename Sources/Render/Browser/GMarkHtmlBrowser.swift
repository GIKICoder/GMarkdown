import UIKit
import WebKit

public class GMarkHtmlBrowser: UIViewController {
    
    private var webView: WKWebView!
    private var htmlString: String
    private var activityIndicator: UIActivityIndicatorView!
    
    init(htmlString: String) {
        self.htmlString = htmlString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebView()
        loadHtmlContent()
    }
    
    private func setupUI() {
        title = "HTML 预览"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(dismissModal))
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        view.addSubview(webView)
    }
    
    private func loadHtmlContent() {
        activityIndicator.startAnimating()
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    @objc private func dismissModal() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - WKNavigationDelegate
extension GMarkHtmlBrowser: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showAlert(title: "加载失败", message: error.localizedDescription)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Public API
extension GMarkHtmlBrowser {
    public static func modal(with htmlString: String, in viewController: UIViewController? = nil) {
        let browser = GMarkHtmlBrowser(htmlString: htmlString)
        let navigationController = UINavigationController(rootViewController: browser)
        navigationController.modalPresentationStyle = .formSheet
        
        let presentingVC = viewController ?? UIApplication.shared.windows.first?.rootViewController
        presentingVC?.present(navigationController, animated: true, completion: nil)
    }
}

