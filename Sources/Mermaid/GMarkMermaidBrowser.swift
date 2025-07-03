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
        let escapedMermaidCode = mermaidCode.replacingOccurrences(of: "'", with: "\'").replacingOccurrences(of: "\n", with: "\\n")
        
        let htmlContent = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Mermaid Diagram</title>
            <script src="mermaid/mermaid.min.js"></script>
            <script>
                mermaid.initialize({ startOnLoad: false });
                
                document.addEventListener('DOMContentLoaded', () => {
                    const insertSvg = function(svgCode, bindFunctions) {
                        document.getElementById('mermaid-diagram').innerHTML = svgCode;
                        window.webkit.messageHandlers.debug.postMessage('Mermaid图表已插入DOM');
                    };
                    mermaid.mermaidAPI.render('mermaid-diagram', '\(escapedMermaidCode)', insertSvg);
                });
            </script>
            <style>
                body { font-family: Arial, sans-serif; margin: 0; padding: 20px; }
                #mermaid-diagram { width: 100%; height: auto; }
            </style>
        </head>
        <body>
            <div id="mermaid-diagram"></div>
        </body>
        </html>
        """
        
        if let bundleURL = Bundle.main.resourceURL?.appendingPathComponent("Assets") {
            webView.loadHTMLString(htmlContent, baseURL: bundleURL)
        } else {
            webView.loadHTMLString(htmlContent, baseURL: nil)
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
        
        webView.evaluateJavaScript("console.log('Mermaid渲染开始'); mermaid.mermaidAPI.render('mermaid-diagram', document.getElementById('mermaid-diagram').textContent, function(svgCode) { document.getElementById('mermaid-diagram').innerHTML = svgCode; window.webkit.messageHandlers.debug.postMessage('Mermaid图表已渲染'); });") { _, error in
            if let error = error {
                print("JavaScript执行错误：\(error.localizedDescription)")
                self.showAlert(title: "渲染错误", message: error.localizedDescription)
            }
        }
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
