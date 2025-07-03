import UIKit
import WebKit

class GMarkMermaidBrowser: UIViewController {
    
    private var webView: WKWebView!
    private var mermaidCode: String
    private var activityIndicator: UIActivityIndicatorView!
    
    init(mermaidCode: String) {
        self.mermaidCode = mermaidCode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupWebView()
        loadMermaidContent()
    }
    
    private func setupUI() {
        title = "Mermaid 预览"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissBrowser))
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()
        if #available(iOS 14.0, *) {
            preferences.allowsContentJavaScript = true
        } else {
            // Fallback on earlier versions
        }
        webConfiguration.defaultWebpagePreferences = preferences
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "debug")
        webConfiguration.userContentController = contentController
        
        webView = WKWebView(frame: view.bounds, configuration: webConfiguration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        
        // 允许加载不安全的内容
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Safari/605.1.15"
        webView.configuration.preferences.javaScriptEnabled = true
        webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        webView.configuration.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        
        view.addSubview(webView)
    }
    
    private func loadMermaidContent() {
        let escapedMermaidCode = mermaidCode.replacingOccurrences(of: "'", with: "\'")
                                            .replacingOccurrences(of: "\n", with: "\\n")
        
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle(for: GMarkMermaidBrowser.self)
        #endif
        
        if let htmlURL = bundle.url(forResource: "mermaid", withExtension: "html") {
            let htmlString = try? String(contentsOf: htmlURL, encoding: .utf8)
            let updatedHtmlString = htmlString?.replacingOccurrences(of: "MERMAID_CODE_PLACEHOLDER", with: escapedMermaidCode)
            
            if let bundleURL = bundle.resourceURL?.appendingPathComponent("Assets") {
                webView.loadHTMLString(updatedHtmlString ?? "", baseURL: bundleURL)
            } else {
                webView.loadHTMLString(updatedHtmlString ?? "", baseURL: nil)
            }
        } else {
            print("Error: mermaid.html not found in Assets/mermaid")
            showAlert(title: "加载失败", message: "无法找到 mermaid.html 文件")
        }
    }
    
    @objc private func dismissBrowser() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - WKNavigationDelegate
extension GMarkMermaidBrowser: WKNavigationDelegate, WKScriptMessageHandler {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        print("WebView加载完成")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        print("WebView加载失败：\(error.localizedDescription)")
        showAlert(title: "加载失败", message: error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        print("WebView预加载失败：\(error.localizedDescription)")
        showAlert(title: "预加载失败", message: error.localizedDescription)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "debug" {
            print("WebView调试信息：\(message.body)")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Public API
extension GMarkMermaidBrowser {
    static func present(from viewController: UIViewController? = nil, mermaidCode: String) {
        let mermaidBrowser = GMarkMermaidBrowser(mermaidCode: mermaidCode)
        let navigationController = UINavigationController(rootViewController: mermaidBrowser)
        navigationController.modalPresentationStyle = .formSheet
        
        if let presentingViewController = viewController ?? UIApplication.shared.keyWindow?.rootViewController {
            presentingViewController.present(navigationController, animated: true, completion: nil)
        } else {
            print("Error: Unable to find a view controller to present from.")
        }
    }
}
