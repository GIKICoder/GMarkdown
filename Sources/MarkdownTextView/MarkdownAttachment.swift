//
//  MarkdownAttachment.swift
//  GMarkdown
//
//  Created by 巩柯 on 2025/7/3.
//

import UIKit

/**
 Describes a custom text attachment object containing a view. SubviewAttachingTextViewBehavior tracks attachments of this class and automatically manages adding and removing subviews in its text view.
 */
@objc(MarkdownAttachment)
open class MarkdownAttachment: NSTextAttachment {

    @objc
    public let viewProvider: MarkdownAttachedViewProvider

    /**
     Initialize the attachment with a view provider.
     */
    @objc
    public init(viewProvider: MarkdownAttachedViewProvider) {
        self.viewProvider = viewProvider
        super.init(data: nil, ofType: nil)
    }

    /**
     Initialize the attachment with a view and an explicit size.
     - Warning: If an attributed string that includes the returned attachment is used in more than one text view at a time, the behavior is not defined.
     */
    @objc
    public convenience init(view: UIView, size: CGSize) {
        let provider = UIViewAttachedViewProvider(view: view)
        self.init(viewProvider: provider)
        self.bounds = CGRect(origin: .zero, size: size)
    }

    /**
     Initialize the attachment with a view and use its current fitting size as the attachment size.
     - Note: If the view does not define a fitting size, its current bounds size is used.
     - Warning: If an attributed string that includes the returned attachment is used in more than one text view at a time, the behavior is not defined.
     */
    @objc
    public convenience init(view: UIView) {
        self.init(view: view, size: view.textAttachmentFittingSize)
    }

    // MARK: - NSTextAttachmentContainer

    open override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        return self.viewProvider.bounds(for: self, textContainer: textContainer, proposedLineFragment: lineFrag, glyphPosition: position)
    }

    open override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        return nil
    }

    // MARK: NSCoding

    public required init?(coder aDecoder: NSCoder) {
        fatalError("MarkdownAttachment cannot be decoded.")
    }

}


// MARK: - Extensions

private extension UIView {

    @objc(md_attachmentFittingSize)
    var textAttachmentFittingSize: CGSize {
        let fittingSize = self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if fittingSize.width > 1e-3 && fittingSize.height > 1e-3 {
            return fittingSize
        } else {
            return self.bounds.size
        }
    }
    
}
