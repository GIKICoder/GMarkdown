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
    
    func generateLatexWithSlow(markup: Paragraph) {
        // 初始化访问者并生成属性文本
        var visitor = GMarkupStringifier()
        let text =  visitor.visit(markup)
        let trimText = trimBrackets(from: text)

        // 初始化渲染器
        var renderer: GMarkLatexToSVGConverter
        do {
            renderer = try GMarkLatexToSVGConverter()
        } catch {
            // 处理渲染器初始化错误
            calculateLatexText()
            updateHashKey()
            return
        }
        
    
        do {
            let svgResult = try renderer.convert(trimText)
#if DEBUG
            print("svgResult: \(svgResult)")
#endif
            if let svgData = svgResult.data(using: .utf8) {
                let renderer = GMarkSVGRender.shared
                let options = GMarkSVGRender.RenderOptions(
                    prefersBitmap: true,
                    preserveAspectRatio: true, targetSize: CGSize(width: style.maxContainerWidth, height: 50)
                )

                if let image = renderer.renderLaTeXSVG(data: svgData) {
                    print("SVG 渲染成功，使用图片")
                    // 使用渲染后的图片
                    latexSize = image.size
                    latexImage = image
                    itemSize = CGSize(width: style.maxContainerWidth, height: image.size.height + style.codeBlockStyle.padding.top + style.codeBlockStyle.padding.top)
                    return
                }
            }
            print("SVG 渲染失败，尝试使用 Macaw 解析")
            // 使用渲染结果
            self.latexSvg = svgResult
            if let node = try? SVGParser.parse(text: svgResult),
               let nodeSize = node.bounds?.size().toCG() {
                let imageSize = CGSize(width: nodeSize.width * 8, height: nodeSize.height * 8)
                self.latexNode = node
                latexKey = trimText
                latexSize = imageSize
                itemSize = CGSize(
                    width: style.maxContainerWidth,
                    height: imageSize.height + style.codeBlockStyle.padding.top + style.codeBlockStyle.padding.bottom
                )
                return
            }
        } catch let error {
            print("LaTeX 渲染错误: \(error.localizedDescription)")
        }
        // 继续后续处理
        calculateLatexText()
        updateHashKey()
    }

    
    func generateLatexNormal(markup: Paragraph) {
    
        var visitor = GMarkupStringifier()
        let text =  visitor.visit(markup)
        let trimText = trimBrackets(from: text)
        if let cached = GMarkCachedManager.shared.getLatexCache(for: trimText) {
            latexSize = cached.size
            latexImage = cached
            itemSize = CGSize(width: style.maxContainerWidth, height: cached.size.height + style.codeBlockStyle.padding.top + style.codeBlockStyle.padding.top)
            return
        }
 
        var mImage = MathImage(latex: trimText, fontSize: style.fonts.current.pointSize, textColor: style.colors.current)
        mImage.font = MathFont.xitsFont
        let (_, image, _) = mImage.asImage()
        if let image = image {
            GMarkCachedManager.shared.setLatexCache(image, for: trimText)
            latexSize = image.size
            latexImage = image
            itemSize = CGSize(width: style.maxContainerWidth, height: image.size.height + style.codeBlockStyle.padding.top + style.codeBlockStyle.padding.top)
        } else if (style.codeBlockStyle.useHighlight == false) {
            attributedText = NSAttributedString(string: text)
            calculateLatexText()
            updateHashKey()
        } else {
            generateLatexWithSlow(markup: markup)
        }
    }
    
    func trimBrackets(from string: String) -> String {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 检查并去掉方括号
        if trimmedString.hasPrefix("[") && trimmedString.hasSuffix("]") {
            return String(trimmedString.dropFirst().dropLast())
        }
        
        // 检查并去掉 $$ 符号
        if trimmedString.hasPrefix("$$") && trimmedString.hasSuffix("$$") {
            return String(trimmedString.dropFirst(2).dropLast(2))
        }
        
        // 检查并去掉单个 $ 符号
        if trimmedString.hasPrefix("$") && trimmedString.hasSuffix("$") {
            return String(trimmedString.dropFirst().dropLast())
        }
        
        return trimmedString
    }

    
    func calculateLatexText() {
        let attr = attributedText
        let builder = MPITextRenderAttributesBuilder()
        builder.attributedText = attr
        builder.maximumNumberOfLines = 0
        let renderAttributes = MPITextRenderAttributes(builder: builder)
        textRender = MPITextRenderer(renderAttributes: renderAttributes, constrainedSize: CGSize(width: style.maxContainerWidth, height: CGFLOAT_MAX))
        
        itemSize = CGSize(width: style.maxContainerWidth, height: textRender?.size().height ?? 0.0)
    }
}
