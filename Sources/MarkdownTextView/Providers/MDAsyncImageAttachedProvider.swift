//
//  MDAsyncImageAttachedProvider.swift
//  GMarkdown
//
//  Created by 巩柯 on 2025/7/3.
//

import UIKit
import Markdown

class MDAsyncImageAttachedProvider: MarkdownAttachedViewProvider {

    let url:String
    
    lazy var imageView = UIImageView()
    
    var markup: Image?
    var style:Style?
    
    init(markup: Image, style:Style) {
        self.url = markup.source ?? ""
        self.markup = markup
        self.style = style
    }
    
    func instantiateView(for attachment: MarkdownAttachment, in behavior: MarkdownAttachingBehavior) -> UIView {
        self.imageView.backgroundColor = .orange
        return self.imageView
    }

    func bounds(for attachment: MarkdownAttachment, textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint) -> CGRect {
        guard let style = self.style else {
            return CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
        }
        return CGRect(origin: .zero, size: CGSize(width: style.maxContainerWidth, height: style.maxContainerWidth))
    }
}
