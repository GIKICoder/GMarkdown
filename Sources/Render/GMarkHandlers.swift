//
//  GMarkHandlers.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/31.
//

import Foundation
import QuickLook
import SafariServices
import UIKit

public class DefaultMarkHandler: MarkHandler {
    public typealias Handler = DefaultMarkHandler
    public var next: Handler?

    private var customHandlers: [String: (Any) -> Bool] = [:]

    private var previewItem: QLPreviewItem?

    public init() {}

    public func handle(_ action: MarkAction) -> Bool {
        switch action {
        case let .textClicked(text):
            print("Text clicked: \(text)")
            return true
        case let .codeBlockCopied(code):
            print("Code block copied: \(code)")
            UIPasteboard.general.string = code
            return true
        case let .linkClicked(url):
            print("Link clicked: \(url)")
            tapLink(url: url)
            return true
        case let .imageClicked(imageSource):
            print("Image clicked: \(imageSource)")
            tapImage(url: imageSource)
            return true
        case let .custom(type, data):
            if let handler = customHandlers[type] {
                return handler(data)
            }
            return false
        }
    }

    // 添加自定义处理逻辑
    public func addCustomHandler(for type: String, handler: @escaping (Any) -> Bool) {
        customHandlers[type] = handler
    }

    // MARK: - action methods

    func tapLink(url: URL) {
        let scheme = url.scheme?.lowercased()

        // 判断协议是否是 http 或 https
        if scheme == "http" || scheme == "https" {
            let safariVC = SFSafariViewController(url: url)
            topViewController()?.present(safariVC, animated: true, completion: nil)
        } else {
            print("不支持的 URL 协议：\(url)")
        }
    }

    func tapImage(url _: URL) {}
}

private extension DefaultMarkHandler {
    func topViewController() -> UIViewController? {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .filter({ $0.isKeyWindow }).first
        else {
            return nil
        }
        if var topController = keyWindow.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}
