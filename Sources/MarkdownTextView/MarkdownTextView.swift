//
//  MarkdownTextView.swift
//  GMarkdown
//
//  Created by GIKI on 2025/7/3.
//

import UIKit

/// 专门用于Markdown渲染的TextView
/// 负责接收AttributedString并进行高性能渲染，支持SubviewAttaching
open class MarkdownTextView: UITextView {
    
    // MARK: - Properties
    
    /// SubviewAttaching行为管理器
    private let attachmentBehavior = MarkdownAttachingBehavior()
    
    /// 是否启用SubviewAttaching功能
    public var isSubviewAttachingEnabled: Bool = true {
        didSet {
            updateAttachmentBehavior()
        }
    }
    
    /// 是否启用高性能渲染优化
    public var isPerformanceOptimized: Bool = true {
        didSet {
            attachmentBehavior.isPerformanceOptimized = isPerformanceOptimized
        }
    }
    
    // MARK: - Initialization
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        setupAttachmentBehavior()
        setupDefaultConfiguration()
    }
    
    private func setupAttachmentBehavior() {
        attachmentBehavior.textView = self
        layoutManager.delegate = attachmentBehavior
        textStorage.delegate = attachmentBehavior
    }
    
    private func setupDefaultConfiguration() {
        // 默认配置
        isEditable = false
        isSelectable = true
        isScrollEnabled = true
        showsVerticalScrollIndicator = true
        showsHorizontalScrollIndicator = false
        
        // 设置默认的文本容器配置
        textContainer.lineFragmentPadding = 0
        textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    // MARK: - Public Methods
    
    /// 设置渲染的AttributedString
    /// - Parameter attributedString: 已经解析和样式化的AttributedString
    public func setAttributedMarkdown(_ attributedString: NSAttributedString) {
        self.attributedText = attributedString
    }
    
    /// 追加AttributedString内容（用于流式渲染）
    /// - Parameter attributedString: 要追加的AttributedString
    public func appendAttributedMarkdown(_ attributedString: NSAttributedString) {
        let mutableText = NSMutableAttributedString(attributedString: self.attributedText)
        mutableText.append(attributedString)
        self.attributedText = mutableText
        
        // 自动滚动到底部
        if isPerformanceOptimized {
            scrollToBottom()
        }
    }
    
    /// 清空内容
    public func clearContent() {
        self.attributedText = NSAttributedString()
    }
    
    /// 滚动到底部
    public func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: max(0, contentSize.height - bounds.height))
        setContentOffset(bottomOffset, animated: false)
    }
    
    // MARK: - Override Methods
    
    open override var textContainerInset: UIEdgeInsets {
        didSet {
            // 文本容器插入变化时需要重新布局附加的子视图
            if isSubviewAttachingEnabled {
                attachmentBehavior.layoutAttachedSubviews()
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // 确保子视图正确布局
        if isSubviewAttachingEnabled {
            attachmentBehavior.layoutAttachedSubviews()
        }
    }
    
    // MARK: - Private Methods
    
    private func updateAttachmentBehavior() {
        if isSubviewAttachingEnabled {
            layoutManager.delegate = attachmentBehavior
            textStorage.delegate = attachmentBehavior
        } else {
            if layoutManager.delegate === attachmentBehavior {
                layoutManager.delegate = nil
            }
            if textStorage.delegate === attachmentBehavior {
                textStorage.delegate = nil
            }
            attachmentBehavior.removeAllAttachedSubviews()
        }
    }
}
