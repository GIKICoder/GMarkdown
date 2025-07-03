//
//  CodeBlockMarkupHandler.swift
//  GMarkdown
//
//  Created by GIKI on 2025/5/13.
//

import Foundation
import Markdown
import MPITextKit
import SwiftMath
import UIKit
public class CodeBlockMarkupHandler: MarkupHandler {
    public init() {
        // 初始化代码
    }
    
    public func canHandle(_ markup: Markup) -> Bool {
        return markup is CodeBlock
    }
    
    public func handle(_ markup: Markup, style: Style?) -> GMarkChunk {
        let chunk = GMarkChunk(chunkType: .Code, children: [markup])
        if let style = style {
            chunk.style = style
        }
        guard let markup = markup as! CodeBlock? else {
            return chunk
        }
        
        chunk.generateCode(markup: markup)
        return chunk
    }
}

// MARK: - Code Chunk

extension GMarkChunk {
    func generateCode(markup: CodeBlock) {
        
        if let cachedAttributed = GMarkCachedManager.shared.getAttributedTextCache(for: markup.code) {
            attributedText = cachedAttributed
            calculateCode()
            updateHashKey()
            return
        }
        
        language = markup.language ?? ""
        codeSource = markup.code
        style.codeBlockStyle.customRender = true
        var visitor = GMarkupVisitor(style: style)
        
        attributedText = visitor.visit(markup)
        // 先去掉cache的逻辑，后续再考虑
        // GMarkCachedManager.shared.setAttributedTextCache(attributedText, for: markup.code)
        calculateCode()
        
        updateHashKey()
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
    }
}


