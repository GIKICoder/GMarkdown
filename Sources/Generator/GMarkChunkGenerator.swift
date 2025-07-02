//
//  GMarkChunkGenerator.swift
//  GMarkRender
//
//  Created by GIKI on 2024/8/1.
//

import Foundation
import Markdown
import MPITextKit
import SwiftMath
import UIKit

// MARK: - Protocols

public protocol ChunkGenerator {
    func generateChunks(from markups: [Markup]) -> [GMarkChunk]
}

public protocol MarkupHandler {
    func canHandle(_ markup: Markup) -> Bool
    func handle(_ markup: Markup, style: Style?) -> GMarkChunk
}

// MARK: - ChunkGenerator Implementation

public class GMarkChunkGenerator: ChunkGenerator {
    public var handlers: [MarkupHandler]
    public var maxAttributedStringLength = 2000
    public var style: Style?
    public var referLoader: ReferLoader?
    public var imageLoader: ImageLoader?
    public var identifier: String = UUID().uuidString
    
    
    public init(handlers: [MarkupHandler] = [
        TableMarkupHandler(),
        CodeBlockMarkupHandler(),
        ThematicBreakHandler(),
    ]) {
        self.handlers = handlers
    }
    
    public func addImageHandler() {
        self.handlers.append(ImageMarkupHandler())
    }
    
    public func addLaTexHandler() {
        self.handlers.append(LaTexMarkupHandler())
    }
    
    public func generateChunks(from markups: [Markup]) -> [GMarkChunk] {
        var chunks: [GMarkChunk] = []
        var currentChunk = GMarkChunk(identifier: identifier,chunkType: .Text)
        if let chunkStyle = style {
            currentChunk.style = chunkStyle
        }
        for markup in markups {
            if let handler = handlers.first(where: { $0.canHandle(markup) }) {
                if !currentChunk.children.isEmpty {
                    chunks.append(currentChunk)
                    currentChunk = GMarkChunk(identifier: identifier,chunkType: .Text)
                    if let chunkStyle = style {
                        currentChunk.style = chunkStyle
                    }
                }
                let chunk = handler.handle(markup, style: style)
                chunk.identifier = identifier
                chunk.updateHashKey()
                chunks.append(chunk)
            } else {
                var visitor = GMarkupVisitor(style: currentChunk.style)
                visitor.referLoader = referLoader
                visitor.imageLoader = imageLoader
                let attributeText = visitor.visit(markup)
                
                if currentChunk.attributedText.length + attributeText.length > maxAttributedStringLength {
                    chunks.append(currentChunk)
                    currentChunk = GMarkChunk(identifier: identifier,chunkType: .Text)
                    if let chunkStyle = style {
                        currentChunk.style = chunkStyle
                    }
                }
                currentChunk.children.append(markup)
                let mutableAttributeText = NSMutableAttributedString(attributedString: currentChunk.attributedText)
                mutableAttributeText.append(attributeText)
                currentChunk.attributedText = mutableAttributeText
                currentChunk.generatorTextRender()
            }
        }
        
        if !currentChunk.children.isEmpty {
            chunks.append(currentChunk)
        }
        chunks.enumerated().forEach { index,chunk in
            chunk.chunkIndex = index
            chunk.updateHashKey()
        }
        return chunks
    }
    
}

// MARK: - MarkupHandler Implementations


public class LaTexHandler: MarkupHandler {
    public init() {}
    
    public func canHandle(_ markup: Markup) -> Bool {
        if markup is Paragraph {
            let markSub = markup.child(at: 0)
            let markSubLast = markup.child(at: markup.childCount - 1)
            
            if let latex = markSub as? InlineHTML, latex.plainText == "<LaTex>" {
                if let latexs = markSubLast as? InlineHTML, latexs.plainText == "</LaTex>" {
                    return true
                }
            }
        }
        return false
    }
    
    public func handle(_ markup: Markup, style _: Style?) -> GMarkChunk {
        let chunk = GMarkChunk(chunkType: .Latex, children: [markup])
        guard let markup = markup as! Paragraph? else {
            return chunk
        }
        chunk.generateLatexNormal(markup: markup)
        return chunk
    }
}


// MARK: - Latex Chunk


extension NSAttributedString {
    func addGradientMask(lastCharCount: Int = 5) -> NSAttributedString {
        let mutableAttr = NSMutableAttributedString(attributedString: self)
        let totalLength = self.length
        
        // 确保字符数量合法
        guard totalLength > 0 && lastCharCount > 0 else { return self }
        
        // 计算需要添加渐变的起始位置
        let startPosition = max(0, totalLength - lastCharCount)
        let gradientLength = min(lastCharCount, totalLength)
        
        // 创建渐变colors数组
        let gradientSteps = gradientLength
        for i in 0..<gradientSteps {
            let progress = Float(i) / Float(gradientSteps)
            let alpha = 1.0 - progress // 从1渐变到0
            
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black.withAlphaComponent(CGFloat(alpha))
            ]
            
            let location = startPosition + i
            mutableAttr.addAttributes(attributes, range: NSRange(location: location, length: 1))
        }
        
        return mutableAttr
    }
}

// MARK: - text Chunk

extension GMarkChunk {
    func generatorTextRender() {
//        attributedText = attributedText.addGradientMask(lastCharCount: 5)
        let attr = attributedText
        let builder = MPITextRenderAttributesBuilder()
        builder.attributedText = attr
        builder.maximumNumberOfLines = 0
        let renderAttributes = MPITextRenderAttributes(builder: builder)
        textRender = MPITextRenderer(renderAttributes: renderAttributes, constrainedSize: CGSize(width: style.maxContainerWidth, height: CGFLOAT_MAX))
        
        itemSize = CGSize(width: style.maxContainerWidth, height: textRender?.size().height ?? 0.0)
        
        updateHashKey()
    }
}
