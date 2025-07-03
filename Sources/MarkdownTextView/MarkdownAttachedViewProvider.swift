//
//  MarkdownAttachedViewProvider.swift
//  GMarkdown
//
//  Created by 巩柯 on 2025/7/3.
//

import UIKit

/**
 Describes a protocol that provides views inserted as subviews into text views that render a `SubviewTextAttachment`, and customizes their layout.
 - Note: Implementing this protocol is encouraged over providing a single view in a `SubviewTextAttachment`, because it allows attributed strings with subview attachments to be rendered in multiple text views at the same time: each text view would get its own subview that corresponds to the attachment.
 */
@objc(MarkdownAttachedViewProvider)
public protocol MarkdownAttachedViewProvider: AnyObject {

    /**
     Returns a view that corresponds to the specified attachment.
     - Note: Each `SubviewAttachingTextViewBehavior` caches instantiated views until the attachment leaves the text container.
     */
    func instantiateView(for attachment: MarkdownAttachment, in behavior: MarkdownAttachingBehavior) -> UIView

    /**
     Returns the layout bounds of the view that corresponds to the specified attachment.
     - Note: Return `attachment.bounds` for default behavior. See `NSTextAttachmentContainer.attachmentBounds(for:, proposedLineFragment:, glyphPosition:, characterIndex:)` method for more details.
     */
    func bounds(for attachment: MarkdownAttachment, textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint) -> CGRect

}


// MARK: - Internal view provider

final internal class UIViewAttachedViewProvider: MarkdownAttachedViewProvider {

    let view: UIView

    init(view: UIView) {
        self.view = view
    }

    func instantiateView(for attachment: MarkdownAttachment, in behavior: MarkdownAttachingBehavior) -> UIView {
        return self.view
    }

    func bounds(for attachment: MarkdownAttachment, textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint) -> CGRect {
        return attachment.bounds
    }

}
