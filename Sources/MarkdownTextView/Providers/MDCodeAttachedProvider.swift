//
//  MDCodeAttachedProvider.swift
//  GMarkdown
//
//  Created by 巩柯 on 2025/7/3.
//

import UIKit
import Markdown
import MPITextKit

class MDCodeAttachedProvider: MarkdownAttachedViewProvider {
    
    private lazy var codeView: GMarkdownCodeView = {
        let codeView = GMarkdownCodeView()
        return codeView
    }()
    
    private let markup: CodeBlock
    private var attributedText: NSAttributedString?
    private let style: Style
    
    private var textRender: MPITextRenderer?
    private var codeSize: CGSize = .zero
    private var itemSize: CGSize = .zero
    private var chunk: GMarkChunk?
    init(markup: CodeBlock, style:Style, attributedText: NSAttributedString) {
        self.markup = markup
        self.style = style
        self.attributedText = attributedText
        calculateCode()
    }
    
    func instantiateView(for attachment: MarkdownAttachment, in behavior: MarkdownAttachingBehavior) -> UIView {
        self.codeView.markChunk = chunk
        return self.codeView
    }

    func bounds(for attachment: MarkdownAttachment, textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint) -> CGRect {
        return CGRect(origin: .zero, size: itemSize)
    }
    
    func calculateCode() {
        let attr = attributedText
        let builder = MPITextRenderAttributesBuilder()
        builder.attributedText = attr
        builder.maximumNumberOfLines = 0
        let renderAttributes = MPITextRenderAttributes(builder: builder)
        let fitsSize = CGSize(width: style.maxContainerWidth * 2, height: CGFLOAT_MAX)
        textRender = MPITextRenderer(renderAttributes: renderAttributes, constrainedSize: fitsSize)
        codeSize = textRender?.size() ?? CGSize(width: style.maxContainerWidth, height: 0)
        let itemHeight = style.codeBlockStyle.padding.top + 32 + 8 + codeSize.height + 8 + style.codeBlockStyle.padding.bottom
        itemSize = CGSize(width: style.maxContainerWidth, height: itemHeight)
        let chunk = GMarkChunk(chunkType: .Code, children: [markup])
        chunk.style = style
        chunk.textRender = textRender
        chunk.language = markup.language ?? ""
        chunk.codeSize = codeSize
        chunk.itemSize = itemSize
        self.chunk = chunk
    }
}
