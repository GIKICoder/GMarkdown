//
//  MDCodeAttachedProvider.swift
//  GMarkdown
//
//  Created by 巩柯 on 2025/7/3.
//

import UIKit
import Markdown

class MDCodeAttachedProvider: MarkdownAttachedViewProvider {
    
    private lazy var codeView: GMarkdownCodeView = {
        let codeView = GMarkdownCodeView()
        return codeView
    }()
    
    private let markup: CodeBlock
    private var attributedText: NSAttributedString?
    private let style: Style
    
    init(markup: CodeBlock, style:Style, attributedText: NSAttributedString) {
        self.markup = markup
        self.style = style
        self.attributedText = attributedText
        calculateSize()
    }
    
    func instantiateView(for attachment: MarkdownAttachment, in behavior: MarkdownAttachingBehavior) -> UIView {
        return self.codeView
    }

    func bounds(for attachment: MarkdownAttachment, textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint) -> CGRect {
        return CGRect(origin: .zero, size: .zero)
    }
    
    private func calculateSize() {
        
    }
}
