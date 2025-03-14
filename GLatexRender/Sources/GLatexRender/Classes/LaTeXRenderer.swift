//
//  LaTeXRenderer.swift
//  iOSLaTeX
//
//  Created by Shuaib Jewon on 7/23/18.
//  Copyright © 2018 shujew. All rights reserved.
//

import Foundation
import WebKit

public class LaTeXRenderer: NSObject {
    public var timeoutInSeconds: Double = 5.0
    public var delayInMilliseconds: Int = 100 /* see comments to understand usage */
    
    public fileprivate(set) var isReady: Bool = false
    
    weak private var parentView: UIView! /* needed to speed up rendering process */
    
    fileprivate var mathJaxCallbackHandler: String = "callbackHandler"
    
    private var webView: WKWebView!
    private var hidingView: UIView? /* used to hide WkWebView while rendering LaTeX */
    private var timeoutTimer: Timer?
    
    private override init() {}
    
    var renderCompletionHander: ((UIImage?, String?)->())?
    
    private var renderQueue: OperationQueue! = OperationQueue()
    
    public init(parentView: UIView) {
        super.init()
        
        self.parentView = parentView
        
        self.renderQueue.maxConcurrentOperationCount = 1
        
#if SWIFT_PACKAGE
    let bundle = Bundle.module
#else
    let bundle = Bundle(for: type(of: self))
#endif
        let bundlePath = bundle.bundlePath
        let htmlTemplatePath = bundle.path(forResource: "MathJaxRenderer", ofType: "html")!
        
        let webViewBaseUrl = URL(fileURLWithPath: bundlePath, isDirectory: true)
        let webViewHtml = try! String(contentsOfFile: htmlTemplatePath)
        
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        
        contentController.add(self, name: self.mathJaxCallbackHandler)
        config.userContentController = contentController
        
        let parentBounds = parentView.bounds
        let webViewFrame = CGRect(origin: parentBounds.origin, size: CGSize(width: parentBounds.size.width, height: parentBounds.size.height))
        
        self.webView = WKWebView(frame: webViewFrame, configuration: config)
        
        /*
         * Need to add WkWebView to view hierarchy to improve loading time (Apple bug)
         * If not added, complex/long LaTeX will take ages to render
         */
        self.webView.isHidden = true
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        self.parentView.addSubview(self.webView)
        self.parentView.sendSubviewToBack(self.webView)
        
        if #available(iOS 11, *) {
            let guide = self.parentView.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                self.webView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
                guide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.webView.bottomAnchor, multiplier: 1.0),
                self.webView.leftAnchor.constraint(equalTo: self.parentView.leftAnchor, constant: 0),
                self.webView.rightAnchor.constraint(equalTo: self.parentView.rightAnchor, constant: 0)
                ])
            
        } else {
            let standardSpacing: CGFloat = 8.0
            NSLayoutConstraint.activate([
                self.webView.topAnchor.constraint(equalTo: self.parentView.topAnchor, constant: standardSpacing),
                self.parentView.bottomAnchor.constraint(equalTo: self.webView.bottomAnchor, constant: standardSpacing),
                self.webView.leftAnchor.constraint(equalTo: self.parentView.leftAnchor, constant: 0),
                self.webView.rightAnchor.constraint(equalTo: self.parentView.rightAnchor, constant: 0)
                ])
        }
        
        /*
         * Figure out why delay is needed here
         * If no delay, webview will appear for a split second
         */
        let delay = DispatchTime.now() + .milliseconds(self.delayInMilliseconds)
        DispatchQueue.main.asyncAfter(deadline: delay) { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.webView.navigationDelegate = self
            strongSelf.webView.uiDelegate = self
            
            strongSelf.webView.loadHTMLString(webViewHtml, baseURL: webViewBaseUrl)
        }
    }
    
    public func render(_ laTeX: String, completion: @escaping (UIImage?, String?)->()) {
        let renderOperation = LaTeXRenderOperation(laTeX, withRenderer: self)
        renderOperation.completionBlock = {
            DispatchQueue.main.async {
                completion(renderOperation.renderedLaTeX, renderOperation.error)
            }
        }
        
        self.renderQueue.addOperation(renderOperation)
    }
    
    internal func startRendering(_ laTeX: String, completion: @escaping (UIImage?, String?)->()) {
        self.renderCompletionHander = completion
        
        self.hidingView = UIView(frame: self.parentView.bounds)
        self.hidingView!.backgroundColor = parentView.backgroundColor
        self.parentView.addSubview(self.hidingView!)
        
        self.parentView.sendSubviewToBack(self.hidingView!)
        self.parentView.sendSubviewToBack(self.webView)
        
        self.timeoutTimer?.invalidate()
        self.webView.stopLoading()
        self.webView.isHidden = false

        /*
         * Need to escape '\' in javascript
         */
        DispatchQueue.main.async { [weak self] in
            let js = "renderLaTeX(`" + laTeX.replacingOccurrences(of: "\\", with: "\\\\") + "`)"
            self?.webView.evaluateJavaScript(js, completionHandler: nil)
        }
        
        self.timeoutTimer = Timer.scheduledTimer(
            timeInterval: self.timeoutInSeconds,
            target: self,
            selector: #selector(self.renderTimeout),
            userInfo: nil,
            repeats: false
        )
    }
    
    @objc private func renderTimeout() {
        self.timeoutTimer?.invalidate()
        
        self.handleLaTeXRenderingFailure("Timed out while rendering LaTeX")
    }
    
    fileprivate func handleLaTeXRenderingFailure(_ message: String) {
        self.timeoutTimer?.invalidate()
        
        self.renderCompletionHander?(nil, message)
    }
    
    
    fileprivate func handleLaTeXRenderingSuccess(message: Any) {
        self.timeoutTimer?.invalidate()
        
        guard let data = (message as? String)?.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data),
            let jsonDict = json as? [String: CGFloat],
            let widthFloat = jsonDict["width"],
            let heightFloat = jsonDict["height"] else {
                
                self.handleLaTeXRenderingFailure("Failure processing MathJax Signal")
                return
        }
        
        self.getLaTeXImage(withWidth: Int(widthFloat), withHeight: Int(heightFloat)) { [weak self] (image, error) in
            guard let strongSelf = self else { return }
            
            if let error = error {
                strongSelf.handleLaTeXRenderingFailure(error)
                return
            }
            
            guard let image = image else {
                strongSelf.handleLaTeXRenderingFailure("Failure grabbing image data from WkWebView")
                return
            }
            
            strongSelf.webView.isHidden = true
            
            if let hidingView = strongSelf.hidingView, let _ = hidingView.superview {
               hidingView.removeFromSuperview()
            }
            
            strongSelf.renderCompletionHander?(image, nil)
        }
    }
    
    private func getLaTeXImage(withWidth width: Int, withHeight height: Int, completion: @escaping (UIImage?, String?) -> ()) {
        let frameAdjustedForLaTeXSize = CGRect(origin: webView.frame.origin, size: CGSize(width: width, height: height))
        self.webView.frame = frameAdjustedForLaTeXSize
        self.hidingView?.frame = frameAdjustedForLaTeXSize
        
        /*
         * If no delay, webview's frame change will not have taken effect yet
         */
        let delay = DispatchTime.now() + .milliseconds(self.delayInMilliseconds)
        DispatchQueue.main.asyncAfter(deadline: delay) { [weak self] in
            guard let strongSelf = self else { return }
            
            UIGraphicsBeginImageContextWithOptions(strongSelf.webView.bounds.size, true, 0)
            strongSelf.webView.drawHierarchy(in: strongSelf.webView.bounds, afterScreenUpdates: true)
            
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
                completion(nil, "Failure while taking WKWebView snapshot")
                return
            }
            
            UIGraphicsEndImageContext()
            
            completion(image, nil)
        }
    }
}

extension LaTeXRenderer: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (message.body as? String) == "ready" {
            self.isReady = true
        } else if message.name == self.mathJaxCallbackHandler {
            self.handleLaTeXRenderingSuccess(message: message.body)
        }
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.handleLaTeXRenderingFailure("WKWebView navigation failed")
        self.isReady = false
    }
}




