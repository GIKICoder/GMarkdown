//
//  LaTexMarkupHandler.swift
//  GMarkdown
//
//  Created by GIKI on 2025/5/13.
//

import Foundation
import Markdown
import MPITextKit
import SwiftMath
import UIKit
import Macaw
import SVGKit

public class LaTexMarkupHandler: MarkupHandler {
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
    
    public func handle(_ markup: Markup, style: Style?) -> GMarkChunk {
        let chunk = GMarkChunk(chunkType: .Latex, children: [markup])
        if let style = style {
            chunk.style = style
        }
        guard let markup = markup as! Paragraph? else {
            return chunk
        }
        chunk.generateLatexNormal(markup: markup)
        return chunk
    }
}

// MARK: - Latex Chunk

extension GMarkChunk {
    
    func generateLatexNormal(markup: Paragraph) {
        // 使用智能渲染方法，内部会自动处理所有渲染策略切换
        let result = GMarkLaTexRender.renderLatexSmart(from: markup, style: style)
        
        if result.success, let image = result.image {
            print("LaTeX 渲染成功，图片尺寸: \(image.size)")
            setupLatexImage(image)
        } else {
            print("LaTeX 渲染失败: \(result.error?.localizedDescription ?? "未知错误")")
            // 渲染失败时使用纯文本作为后备
            generateLatexAsPlainText(from: markup)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func setupLatexImage(_ image: UIImage) {
        latexSize = image.size
        latexImage = image
        let padding = style.codeBlockStyle.padding
        itemSize = CGSize(
            width: style.maxContainerWidth, 
            height: image.size.height + padding.top + padding.bottom
        )
    }
    
    private func generateLatexAsPlainText(from markup: Paragraph) {
        var visitor = GMarkupStringifier()
        let text = visitor.visit(markup)
        attributedText = NSAttributedString(string: text)
        calculateLatexText()
        updateHashKey()
    }
    
    func calculateLatexText() {
        let attr = attributedText
        let builder = MPITextRenderAttributesBuilder()
        builder.attributedText = attr
        builder.maximumNumberOfLines = 0
        let renderAttributes = MPITextRenderAttributes(builder: builder)
        textRender = MPITextRenderer(
            renderAttributes: renderAttributes, 
            constrainedSize: CGSize(width: style.maxContainerWidth, height: CGFLOAT_MAX)
        )
        
        itemSize = CGSize(width: style.maxContainerWidth, height: textRender?.size().height ?? 0.0)
    }
}
