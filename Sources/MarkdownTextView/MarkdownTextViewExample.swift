//
//  MarkdownTextViewExample.swift
//  GMarkdown
//
//  Created by GIKI on 2025/7/3.
//

import UIKit

/// MarkdownTextView使用示例
/// 演示如何使用MarkdownTextView进行渲染
@available(iOS 13.4, *)
public class MarkdownTextViewExample {
    
    // MARK: - Example 1: 基本使用
    
    /// 基本的MarkdownTextView使用示例
    public static func createBasicMarkdownTextView() -> MarkdownTextView {
        let textView = MarkdownTextView()
        textView.backgroundColor = UIColor.systemBackground
        textView.isSubviewAttachingEnabled = true
        textView.isPerformanceOptimized = true
        
        return textView
    }
    
    // MARK: - Example 2: 使用AttributedString
    
    /// 演示如何创建包含SubviewTextAttachment的AttributedString
    public static func createAttributedStringWithAttachment() -> NSAttributedString {
        let mutableString = NSMutableAttributedString()
        
        // 添加标题
        let title = NSAttributedString(
            string: "Markdown TextView Example\n\n",
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.label
            ]
        )
        mutableString.append(title)
        
        // 添加普通文本
        let content = NSAttributedString(
            string: "This is a MarkdownTextView that supports SubviewAttaching.\n\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.label
            ]
        )
        mutableString.append(content)
        
        // 添加内嵌视图
        let customView = createCustomView()
        let attachment = SubviewTextAttachment(view: customView)
        let attachmentString = NSAttributedString(attachment: attachment)
        mutableString.append(attachmentString)
        
        // 添加结尾文本
        let footer = NSAttributedString(
            string: "\n\nThe above is a custom view embedded in the text.",
            attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
        mutableString.append(footer)
        
        return mutableString
    }
    
    // MARK: - Example 3: 创建自定义视图
    
    /// 创建一个自定义视图用于演示
    private static func createCustomView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemBlue.cgColor
        
        let label = UILabel()
        label.text = "Custom View"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.systemBlue
        label.textAlignment = .center
        
        containerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 200),
            containerView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        return containerView
    }
    
    // MARK: - Example 4: 完整的视图控制器示例
    
    /// 创建一个完整的视图控制器示例
    public static func createExampleViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor.systemBackground
        
        let textView = createBasicMarkdownTextView()
        let attributedString = createAttributedStringWithAttachment()
        
        textView.setAttributedMarkdown(attributedString)
        
        viewController.view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        return viewController
    }
    
    // MARK: - Example 5: 流式渲染示例
    
    /// 演示流式渲染的用法
    public static func demonstrateStreamRendering(textView: MarkdownTextView) {
        // 清空现有内容
        textView.clearContent()
        
        // 模拟流式数据
        let chunks = [
            "# Streaming Markdown\n\n",
            "This is a demonstration of streaming rendering.\n\n",
            "Text is being added **gradually** to show the streaming effect.\n\n",
            "- Item 1\n",
            "- Item 2\n",
            "- Item 3\n\n",
            "End of streaming content."
        ]
        
        // 逐步添加内容
        for (index, chunk) in chunks.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(index) * 0.5) {
                let attributedChunk = NSAttributedString(
                    string: chunk,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 16),
                        .foregroundColor: UIColor.label
                    ]
                )
                textView.appendAttributedMarkdown(attributedChunk)
            }
        }
    }
}
