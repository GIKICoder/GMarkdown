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
import Macaw

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
        BlockQuoteMarkupHandler(),
        ThematicBreakHandler(),
    ]) {
        self.handlers = handlers
    }
    
    public func addImageHandler() {
        self.handlers.append(ImageHandler())
    }
    
    public func addLaTexHandler() {
        self.handlers.append(LaTexHandler())
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

public class TableMarkupHandler: MarkupHandler {
    public init() {
        // 初始化代码
    }
    
    public func canHandle(_ markup: Markup) -> Bool {
        return markup is Table
    }
    
    public func handle(_ markup: Markup, style: Style?) -> GMarkChunk {
        let chunk = GMarkChunk(chunkType: .Table, children: [markup])
        if let style = style {
            chunk.style = style
        }
        guard let markup = markup as! Table? else {
            return chunk
        }
        chunk.generateTable(markup: markup)
        return chunk
    }
}

public class CodeBlockMarkupHandler: MarkupHandler {
    public init() {
        // 初始化代码
    }
    
    public func canHandle(_ markup: Markup) -> Bool {
        return markup is CodeBlock
    }
    
    public func handle(_ markup: Markup, style: Style?) -> GMarkChunk {
        var chunk = GMarkChunk(chunkType: .Code, children: [markup])
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

public class BlockQuoteMarkupHandler: MarkupHandler {
    public init() {
        // 初始化代码
    }
    
    public func canHandle(_: Markup) -> Bool {
        //    return markup is BlockQuote
        return false
    }
    
    public func handle(_ markup: Markup, style _: Style?) -> GMarkChunk {
        return GMarkChunk(chunkType: .BlockQuote, children: [markup])
    }
}

public class ThematicBreakHandler: MarkupHandler {
    public init() {
        
    }
    
    public func canHandle(_ markup: Markup) -> Bool {
        return markup is ThematicBreak
    }
    
    public func handle(_ markup: Markup, style _: Style?) -> GMarkChunk {
        let chunk = GMarkChunk(chunkType: .Thematic, children: [markup])
        chunk.itemSize = CGSize(width: chunk.style.maxContainerWidth, height: 30)
        return chunk
    }
}

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
        chunk.generateLatex(markup: markup)
        return chunk
    }
}

public class ImageHandler: MarkupHandler {
    public init() {
        // 初始化代码
    }
    
    public func canHandle(_ markup: Markup) -> Bool {
        if markup is Paragraph {
            let markSub = markup.child(at: 0)
            return markSub is Markdown.Image
        }
        return markup is Markdown.Image
    }
    
    public func handle(_ markup: Markup, style _: Style?) -> GMarkChunk {
        let chunk = GMarkChunk(chunkType: .Image, children: [markup])
        var imgSource: String?
        if markup is Paragraph {
            if let markSub = markup.child(at: 0) as? Markdown.Image {
                imgSource = markSub.source
            }
        }
        if let mark = markup as? Markdown.Image {
            imgSource = mark.source
        }
        chunk.source = imgSource ?? ""
        chunk.itemSize = CGSize(width: chunk.style.maxContainerWidth, height: 100)
        return chunk
    }
    
    func splitText(text: String) -> [String]? {
        let separators = CharacterSet(charactersIn: ";")
        let sentences = text.components(separatedBy: separators)
        
        let filteredSentences = sentences.filter { !$0.isEmpty }
        
        return filteredSentences
    }
    
    func splitTextToNums(text: String) -> [String]? {
        let separators = CharacterSet(charactersIn: ",")
        let sentences = text.components(separatedBy: separators)
        
        let filteredSentences = sentences.filter { !$0.isEmpty }
        
        return filteredSentences
    }
}

// MARK: - Latex Chunk

extension GMarkChunk {
    
    func generateLatex(markup: Paragraph) {
        // 初始化访问者并生成属性文本
        var visitor = GMarkupVisitor(style: style)
        visitor.ignoreLatex = true
        attributedText = visitor.visit(markup)
        
        // 获取并修剪文本
        let text = attributedText.string
        let trimText = trimBrackets(from: text)
        print("trimText: \(trimText)")
        guard let filepath = Bundle.main.path(forResource: "markdownv2", ofType: nil),
              let filecontents = try? String(contentsOfFile: filepath, encoding: .utf8) else {
            return
        }
        
        // 初始化渲染器
        var renderer: GMarkLatexRender
        do {
            renderer = try GMarkLatexRender()
        } catch {
            // 处理渲染器初始化错误
            print("渲染器初始化失败: \(error)")
            calculateLatexText()
            updateHashKey()
            return
        }
        
        // 定义变量来存储渲染结果和可能的错误
        var svgResult: String?
        var renderError: Error?
        do {
            svgResult = try renderer.convert(filecontents)
        } catch {
            renderError = error
        }
        
         if let svg = svgResult {
            // 使用渲染结果
            self.latexSvg = svg
             print("Latex SVG: \(svg)")
             if let node = try? SVGParser.parse(text: svg),
                let nodeSize = node.bounds?.size().toCG() {
                 let imageSize = CGSize(width: nodeSize.width*8, height: nodeSize.height*8)
                 self.latexNode = node
                 latexSize = imageSize
                 itemSize = CGSize(width: style.maxContainerWidth, height: imageSize.height + style.codeBlockStyle.padding.top + style.codeBlockStyle.padding.top)
                 return
             }
        }
        // 继续后续处理
        calculateLatexText()
        updateHashKey()
    }

    
    func generateLatexV2(markup: Paragraph) {
        var visitor = GMarkupVisitor(style: style)
        visitor.ignoreLatex = true
        attributedText = visitor.visit(markup)
        
        let text = attributedText.string
        let trimText = trimBrackets(from: text)
        var mImage = MathImage(latex: trimText, fontSize: style.fonts.current.pointSize, textColor: style.colors.current)
        mImage.font = MathFont.xitsFont
        let (_, image) = mImage.asImage()
        if let image = image {
            latexSize = image.size
            latexImage = image
            itemSize = CGSize(width: style.maxContainerWidth, height: image.size.height + style.codeBlockStyle.padding.top + style.codeBlockStyle.padding.top)
            return
        }
        calculateLatexText()
        updateHashKey()
    }
    
    func trimBrackets(from string: String) -> String {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedString.hasPrefix("[") && (trimmedString.hasSuffix("]")) {
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
        if style.needTruncation {
            let tbuilder = MPITextRenderAttributesBuilder()
            tbuilder.attributedText = attr
            tbuilder.maximumNumberOfLines = UInt(style.maximumNumberOfLines)
            tbuilder.truncationAttributedText = generateTruncation()
            let tRenderAttributes = MPITextRenderAttributes(builder: tbuilder)
            truncationTextRender = MPITextRenderer(renderAttributes: tRenderAttributes, constrainedSize: CGSize(width: style.maxContainerWidth, height: CGFLOAT_MAX))
            
            truncationItemSize = CGSize(width: style.maxContainerWidth, height: truncationTextRender?.size().height ?? 0.0)
        }
        
        updateHashKey()
    }
    
    func generateTruncation() -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .font: style.fonts.h6,
            .foregroundColor: style.colors.current,
        ]
        let normalText = NSAttributedString(string: "...", attributes: normalTextAttributes)
        attributedString.append(normalText)
        
        let expandTextAttributes: [NSAttributedString.Key: Any] = [
            .font: style.fonts.current,
            .foregroundColor: UIColor(red: 0, green: 0.439, blue: 0.788, alpha: 1),
        ]
        let expandText = NSAttributedString(string: "Expand".localized, attributes: expandTextAttributes)
        attributedString.append(expandText)
        
        if let image = UIImage(named: "detail_chevron_down") {
            let attachment = MPITextAttachment()
            attachment.image = image
            attachment.bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            let attachmentString = NSAttributedString(attachment: attachment)
            attributedString.append(attachmentString)
        }
        
        let mpiLink = MPITextLink()
        mpiLink.value = "Truncation" as (any NSObjectProtocol)?
        attributedString.addAttribute(.MPILink, value: mpiLink, range: NSRange(location: 3, length: attributedString.length - 3))
        
        return attributedString.copy() as! NSAttributedString
    }
}

// MARK: - Code Chunk

extension GMarkChunk {
    func generateCode(markup: CodeBlock) {
        language = markup.language ?? ""
        style.codeBlockStyle.customRender = true
        style.codeBlockStyle.useHighlight = true
        var visitor = GMarkupVisitor(style: style)
        
        attributedText = visitor.visit(markup)
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

// MARK: - Table Chunk

extension GMarkChunk {
    func generateTable(markup: Table) {
        var style = style
        style.useMPTextKit = true
        style.imageStyle.size = CGSize(width: 60, height: 60)
        var visitor = GMarkupTableVisitor(style: style)
        let table = visitor.visit(markup)
        calculateTable(table: table)
        
        updateHashKey()
    }
    
    func calculateTable(table: GMarkTable?) {
        guard let table = table else {
            return
        }
        tableRender = GMarkTableRender(markTable: table, style: style)
        itemSize = CGSize(width: style.maxContainerWidth, height: tableRender?.tableHeight ?? 0)
    }
}



// MARK: - Localized

extension String {
    
    /// Localized string
    ///
    /// Example:
    /// ```
    /// "Hello".localized
    /// ```
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Localized string with arguments
    ///
    /// Example:
    /// ```
    /// "Hello, %@!".localized("World")
    /// "Hey, %@, how are you? %d years to see".localized("John", 20)
    /// ```
    func localized(_ args: any CVarArg...) -> String {
        return String(format: localized, args)
    }
    
    /// Localized string with custom path
    ///
    /// Example:
    /// ```
    /// "Hello".localized(tableName: "Custom")
    /// ```
    func localize(
        tableName: String? = nil,
        bundle: Bundle = Bundle.main,
        comment: String = ""
    ) -> String {
        return NSLocalizedString(
            self,
            tableName: tableName,
            bundle: bundle,
            value: "",
            comment: comment
        )
    }
    
}
