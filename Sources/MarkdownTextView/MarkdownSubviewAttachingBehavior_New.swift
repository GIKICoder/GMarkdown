//
//  MarkdownSubviewAttachingBehavior.swift
//  GMarkdown
//
//  Created by GIKI on 2025/7/3.
//

import UIKit

/// MarkdownTextView的SubviewAttaching行为管理器
/// 基于原有的SubviewAttachingTextViewBehavior进行优化
@available(iOS 13.4, *)
open class MarkdownSubviewAttachingBehavior: NSObject {
    
    // MARK: - Properties
    
    @objc
    open weak var textView: UITextView? {
        willSet {
            removeAllAttachedSubviews()
        }
        didSet {
            updateAttachedSubviews()
            layoutAttachedSubviews()
        }
    }
    
    /// 是否启用性能优化模式
    public var isPerformanceOptimized: Bool = true
    
    /// 附加视图的缓存映射表
    private let attachedViews = NSMapTable<TextAttachedViewProvider, UIView>.strongToStrongObjects()
    
    /// 当前附加的视图提供者数组
    private var attachedProviders: Array<TextAttachedViewProvider> {
        return Array(self.attachedViews.keyEnumerator()) as! Array<TextAttachedViewProvider>
    }
    
    // MARK: - Public Methods
    
    /**
     添加附加视图作为子视图，移除不再附加的子视图
     该方法在文本视图的文本属性改变时自动调用
     */
    @objc
    open func updateAttachedSubviews() {
        guard let textView = self.textView else {
            return
        }
        
        // 收集所有SubviewTextAttachment附件
        let subviewAttachments = textView.textStorage.subviewAttachmentRanges.map { $0.attachment }
        
        // 移除提供者不再附加的视图
        for provider in self.attachedProviders {
            if (subviewAttachments.contains { $0.viewProvider === provider } == false) {
                self.attachedViews.object(forKey: provider)?.removeFromSuperview()
                self.attachedViews.removeObject(forKey: provider)
            }
        }
        
        // 插入新附加的视图
        let attachmentsToAdd = subviewAttachments.filter {
            self.attachedViews.object(forKey: $0.viewProvider) == nil
        }
        
        for attachment in attachmentsToAdd {
            let provider = attachment.viewProvider
            let view = provider.instantiateView(for: attachment, in: self)
            
            view.translatesAutoresizingMaskIntoConstraints = true
            view.autoresizingMask = []
            
            textView.addSubview(view)
            self.attachedViews.setObject(view, forKey: provider)
        }
    }
    
    /**
     移除所有附加的子视图
     */
    @objc
    open func removeAllAttachedSubviews() {
        for provider in self.attachedProviders {
            self.attachedViews.object(forKey: provider)?.removeFromSuperview()
        }
        self.attachedViews.removeAllObjects()
    }
    
    /**
     根据布局管理器对所有附加的子视图进行布局
     */
    @objc
    open func layoutAttachedSubviews() {
        guard let textView = self.textView else {
            return
        }
        
        let layoutManager = textView.layoutManager
        let scaleFactor = textView.window?.screen.scale ?? UIScreen.main.scale
        
        // 对每个附加的子视图，找到其关联的附件并根据其文本布局定位
        let attachmentRanges = textView.textStorage.subviewAttachmentRanges
        
        for (attachment, range) in attachmentRanges {
            guard let view = self.attachedViews.object(forKey: attachment.viewProvider) else {
                continue
            }
            
            guard view.superview === textView else {
                continue
            }
            
            guard let attachmentRect = Self.boundingRect(forAttachmentCharacterAt: range.location, layoutManager: layoutManager) else {
                view.isHidden = true
                continue
            }
            
            let convertedRect = textView.convertRectFromTextContainer(attachmentRect)
            let integralRect = CGRect(
                origin: convertedRect.origin.integral(withScaleFactor: scaleFactor),
                size: convertedRect.size
            )
            
            // 性能优化：只处理可见区域的视图
            if isPerformanceOptimized {
                let visibleBounds = textView.bounds
                let isVisible = visibleBounds.intersects(integralRect)
                if !isVisible {
                    view.isHidden = true
                    continue
                }
            }
            
            UIView.performWithoutAnimation {
                view.frame = integralRect
                view.isHidden = false
            }
        }
    }
    
    // MARK: - Private Methods
    
    private static func boundingRect(forAttachmentCharacterAt characterIndex: Int, layoutManager: NSLayoutManager) -> CGRect? {
        let glyphRange = layoutManager.glyphRange(forCharacterRange: NSMakeRange(characterIndex, 1), actualCharacterRange: nil)
        let glyphIndex = glyphRange.location
        
        guard glyphIndex != NSNotFound && glyphRange.length == 1 else {
            return nil
        }
        
        let attachmentSize = layoutManager.attachmentSize(forGlyphAt: glyphIndex)
        guard attachmentSize.width > 0.0 && attachmentSize.height > 0.0 else {
            return nil
        }
        
        let lineFragmentRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil)
        let glyphLocation = layoutManager.location(forGlyphAt: glyphIndex)
        
        guard lineFragmentRect.width > 0.0 && lineFragmentRect.height > 0.0 else {
            return nil
        }
        
        return CGRect(
            origin: CGPoint(
                x: lineFragmentRect.minX + glyphLocation.x,
                y: lineFragmentRect.minY + glyphLocation.y - attachmentSize.height
            ),
            size: attachmentSize
        )
    }
}

// MARK: - NSLayoutManagerDelegate

@available(iOS 13.4, *)
extension MarkdownSubviewAttachingBehavior: NSLayoutManagerDelegate {
    
    public func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        if layoutFinishedFlag {
            self.layoutAttachedSubviews()
        }
    }
}

// MARK: - NSTextStorageDelegate

@available(iOS 13.4, *)
extension MarkdownSubviewAttachingBehavior: NSTextStorageDelegate {
    
    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask.contains(.editedAttributes) {
            self.updateAttachedSubviews()
        }
    }
}

// MARK: - Extensions

private extension CGPoint {
    
    func integral(withScaleFactor scaleFactor: CGFloat) -> CGPoint {
        guard scaleFactor > 0.0 else {
            return self
        }
        
        return CGPoint(
            x: round(self.x * scaleFactor) / scaleFactor,
            y: round(self.y * scaleFactor) / scaleFactor
        )
    }
}

private extension NSAttributedString {

    var subviewAttachmentRanges: [(attachment: SubviewTextAttachment, range: NSRange)] {
        var ranges = [(SubviewTextAttachment, NSRange)]()

        let fullRange = NSRange(location: 0, length: self.length)
        self.enumerateAttribute(NSAttributedString.Key.attachment, in: fullRange) { value, range, _ in
            if let attachment = value as? SubviewTextAttachment {
                ranges.append((attachment, range))
            }
        }

        return ranges
    }
}
