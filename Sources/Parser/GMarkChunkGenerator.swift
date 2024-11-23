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
    
    public init(handlers: [MarkupHandler] = [
        DotlineCardHandler(),
        HtmlHandler(),
        TableMarkupHandler(),
        CodeBlockMarkupHandler(),
        BlockQuoteMarkupHandler(),
        ThematicBreakHandler(),
        ImageHandler(),
        LaTexHandler(),
    ]) {
        self.handlers = handlers
    }
    
    public func generateChunks(from markups: [Markup]) -> [GMarkChunk] {
        var chunks: [GMarkChunk] = []
        var currentChunk = GMarkChunk(chunkType: .Text)
        if let chunkStyle = style {
            currentChunk.style = chunkStyle
        }
        
        var isInDotlineCard = false
        var dotlineCardMarkups: [Markup] = []
        
        for markup in markups {
            if let handler = handlers.first(where: { $0.canHandle(markup) }) {
                // 检查是否当前在 <dotline-card> 内部
                if isInDotlineCard {
                    dotlineCardMarkups.append(markup)
                    // 检查是否是 </dotline-card>
                    if let htmlBlock = markup as? HTMLBlock {
                        let content = htmlBlock.rawHTML.trimmingCharacters(in: .whitespacesAndNewlines)
                        if content == "</dotline-card>" {
                            // 结束 <dotline-card>，生成一个 GMarkChunk
                            let dc = DotlineCardHandler()
                            dc.referLoader = referLoader
                            let chunk = dc.handle(dotlineCardMarkups, style: style)
                            
                            chunks.append(chunk)
                            // 重置状态
                            isInDotlineCard = false
                            dotlineCardMarkups.removeAll()
                        }
                    }
                    continue // 继续处理下一个 markup
                }
                
                // 检查是否是 <dotline-card> 开始
                if let htmlBlock = markup as? HTMLBlock {
                    let content = htmlBlock.rawHTML.trimmingCharacters(in: .whitespacesAndNewlines)
                    if content == "<dotline-card>" {
                        isInDotlineCard = true
                        dotlineCardMarkups.append(markup)
                        continue // 开始收集 <dotline-card> 内的 markups
                    }
                }
                
                // 处理非 <dotline-card> 的情况
                if !currentChunk.children.isEmpty {
                    chunks.append(currentChunk)
                    currentChunk = GMarkChunk(chunkType: .Text)
                    if let chunkStyle = style {
                        currentChunk.style = chunkStyle
                    }
                }
                let chunk = handler.handle(markup, style: style)
                chunks.append(chunk)
            } else {
                if isInDotlineCard {
                    dotlineCardMarkups.append(markup)
                    // 检查是否是 </dotline-card>
                    if let htmlBlock = markup as? HTMLBlock {
                        let content = htmlBlock.rawHTML.trimmingCharacters(in: .whitespacesAndNewlines)
                        if content == "</dotline-card>" {
                            // 结束 <dotline-card>，生成一个 GMarkChunk
                            let dc = DotlineCardHandler()
                            dc.referLoader = referLoader
                            let chunk = dc.handle(dotlineCardMarkups, style: style)
                            chunks.append(chunk)
                            // 重置状态
                            isInDotlineCard = false
                            dotlineCardMarkups.removeAll()
                        }
                    }
                    continue
                }
                
                var visitor = GMarkupVisitor(style: currentChunk.style)
                visitor.referLoader = referLoader
                let attributeText = visitor.visit(markup)
                
                if (currentChunk.attributeText?.length ?? 0) + attributeText.length > maxAttributedStringLength {
                    chunks.append(currentChunk)
                    currentChunk = GMarkChunk(children: [], chunkType: .Text)
                    if let chunkStyle = style {
                        currentChunk.style = chunkStyle
                    }
                }
                currentChunk.children.append(markup)
                let mutableAttributeText = NSMutableAttributedString(attributedString: currentChunk.attributeText ?? NSAttributedString())
                mutableAttributeText.append(attributeText)
                currentChunk.attributeText = mutableAttributeText
                currentChunk.generatorTextRender()
            }
        }
        
        if !currentChunk.children.isEmpty {
            chunks.append(currentChunk)
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
        var chunk = GMarkChunk(children: [markup], chunkType: .Table)
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
        var chunk = GMarkChunk(children: [markup], chunkType: .Code)
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
        return GMarkChunk(children: [markup], chunkType: .BlockQuote)
    }
}

public class ThematicBreakHandler: MarkupHandler {
    public init() {
        // 初始化代码
    }
    
    public func canHandle(_ markup: Markup) -> Bool {
        return markup is ThematicBreak
    }
    
    public func handle(_ markup: Markup, style _: Style?) -> GMarkChunk {
        var chunk = GMarkChunk(children: [markup], chunkType: .Thematic)
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
        var chunk = GMarkChunk(children: [markup], chunkType: .Latex)
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
            return markSub is Image
        }
        return markup is Image
    }
    
    public func handle(_ markup: Markup, style _: Style?) -> GMarkChunk {
        var chunk = GMarkChunk(children: [markup], chunkType: .Image)
        var imgSource: String?
        if markup is Paragraph {
            if let markSub = markup.child(at: 0) as? Image {
                imgSource = markSub.source
            }
        }
        if let mark = markup as? Image {
            imgSource = mark.source
        }
        chunk.source = imgSource
        if let im = imgSource {
            let splites = splitText(text: im)
            chunk.sourceTemplate = splites?.first
            if splites?.count ?? 0 > 1, let num = splites?.last {
                chunk.sourceNums = splitTextToNums(text: num)
            }
        }
        
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
    mutating func generateLatex(markup: Paragraph) {
        var visitor = GMarkupVisitor(style: style)
        visitor.ignoreLatex = true
        attributeText = visitor.visit(markup)
        
        let string = attributeText?.string
        guard let text = attributeText?.string else {
            calculateLatexText()
            return
        }
        let trimText = trimBrackets(from: text)
        var mImage = MathImage(latex: trimText, fontSize: style.fonts.current.pointSize, textColor: style.colors.current)
        mImage.font = MathFont.xitsFont
        let (_, image) = mImage.asImage()
        if let image = image {
            itemSize = CGSize(width: style.maxContainerWidth, height: image.size.height + style.codeBlockStyle.padding.top + style.codeBlockStyle.padding.top)
            latexSize = image.size
            latexImage = image
            return
        }
        calculateLatexText()
    }
    
    mutating func trimBrackets(from string: String) -> String {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedString.hasPrefix("[") && (trimmedString.hasSuffix("]")) {
            return String(trimmedString.dropFirst().dropLast())
        }
        return trimmedString
    }
    
    mutating func calculateLatexText() {
        guard let attr = attributeText else {
            return
        }
        
        let builder = MPITextRenderAttributesBuilder()
        builder.attributedText = attr
        builder.maximumNumberOfLines = 0
        let renderAttributes = MPITextRenderAttributes(builder: builder)
        textRender = MPITextRenderer(renderAttributes: renderAttributes, constrainedSize: CGSize(width: style.maxContainerWidth, height: CGFLOAT_MAX))
        
        itemSize = CGSize(width: style.maxContainerWidth, height: textRender?.size().height ?? 0.0)
    }
}

// MARK: - text Chunk

extension GMarkChunk {
    mutating func generatorTextRender() {
        guard let attr = attributeText else {
            return
        }
        
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
    mutating func generateCode(markup: CodeBlock) {
        language = markup.language
        style.codeBlockStyle.customRender = true
        var visitor = GMarkupVisitor(style: style)
        
        attributeText = visitor.visit(markup)
        calculateCode()
    }
    
    mutating func calculateCode() {
        guard let attr = attributeText else {
            return
        }
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
    mutating func generateTable(markup: Table) {
        var style = style ?? MarkdownStyle.defaultStyle()
        style.useMPTextKit = true
        style.imageStyle.size = CGSize(width: 60, height: 60)
        var visitor = GMarkupTableVisitor(style: style)
        let table = visitor.visit(markup)
        calculateTable(table: table)
    }
    
    mutating func calculateTable(table: GMarkTable?) {
        guard let table = table else {
            return
        }
        tableRender = GMarkTableRender(markTable: table, style: style)
        itemSize = CGSize(width: style.maxContainerWidth, height: tableRender?.tableHeight ?? 0)
    }
}

public struct GMarkTableRender {
    public let markTable: GMarkTable
    public let style: Style
    public var headerRenders: [MPITextRenderer]? = []
    public var bodyRenders: [[MPITextRenderer]]? = []
    public var tableHeight: CGFloat?
    public init(markTable: GMarkTable, style: Style) {
        self.markTable = markTable
        self.style = style
        setupTableRender()
    }
    
    mutating func setupTableRender() {
        let maxW = style.tableStyle.cellMaximumWidth
        let defaultH = style.tableStyle.cellHeight
        let paddingH = style.tableStyle.cellPadding.top + style.tableStyle.cellPadding.bottom
        var height = defaultH
        markTable.headers?.enumerated().forEach { _, attr in
            let builder = MPITextRenderAttributesBuilder()
            builder.attributedText = attr
            builder.maximumNumberOfLines = UInt(style.tableStyle.maximumNumberOfLines)
            let renderAttributes = MPITextRenderAttributes(builder: builder)
            let fitsSize = CGSize(width: maxW, height: CGFLOAT_MAX)
            let textRender = MPITextRenderer(renderAttributes: renderAttributes, constrainedSize: fitsSize)
            headerRenders?.append(textRender)
            height = max(textRender.size().height + paddingH, height)
        }
        
        markTable.bodys?.enumerated().forEach { _, attrs in
            var rowRenders: [MPITextRenderer] = []
            var maxRowHeight = 0.0
            for (_, attr) in attrs.enumerated() {
                let builder = MPITextRenderAttributesBuilder()
                builder.attributedText = attr
                builder.maximumNumberOfLines = UInt(style.tableStyle.maximumNumberOfLines)
                let renderAttributes = MPITextRenderAttributes(builder: builder)
                let fitsSize = CGSize(width: maxW, height: CGFLOAT_MAX)
                let textRender = MPITextRenderer(renderAttributes: renderAttributes, constrainedSize: fitsSize)
                rowRenders.append(textRender)
                maxRowHeight = max(textRender.size().height + paddingH, defaultH)
            }
            height += maxRowHeight
            bodyRenders?.append(rowRenders)
        }
        
        height += style.tableStyle.padding.top + style.tableStyle.padding.bottom
        tableHeight = height
    }
}

struct DotlineTagContent {
    let type: String
    let content: String
}

public class HtmlHandler: MarkupHandler {
    public init() {
        // 初始化代码
    }
    
    public func canHandle(_ markup: Markup) -> Bool {
        if let htmlBlock = markup as? HTMLBlock,htmlBlock.rawHTML.hasPrefix("<dotline-") {
            return true
        }
        return false
    }
    
    public func handle(_ markup: Markup, style: Style?) -> GMarkChunk {
        
        
        // 解析 <dotline-*> 标签内容
        if let htmlBlock = markup as? HTMLBlock {
            let parsedTags = parseDotlineTags(from: htmlBlock.rawHTML)
            if let tag = parsedTags.first {
                if tag.type == "card-type" {
                    var chunk = GMarkChunk(children: [markup], chunkType: .DotlineType)
                    chunk.style = style ?? MarkdownStyle.defaultStyle()
                    chunk.cardType = tag.content
                    chunk.itemSize = CGSize(width: style?.maxContainerWidth ?? 0, height: 0)
                    return chunk
                } else if tag.type == "summary" {
                    var textChunk = GMarkChunk(children: [markup], chunkType: .Text)
                    textChunk.style = style ?? MarkdownStyle.defaultStyle()
                    var attributeText = defaultAttribute(from: tag.content, style: textChunk.style)
                    textChunk.attributeText = attributeText
                    textChunk.generatorTextRender()
                    return textChunk
                }
            }
        }
        var chunk = GMarkChunk(children: [markup], chunkType: .Html)
        chunk.style = style ?? MarkdownStyle.defaultStyle()
        chunk.itemSize = CGSize(width: style?.maxContainerWidth ?? 0, height: 0)
        return chunk
    }
    func defaultAttribute(from text: String, style:Style) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: text)

        var attributes: [NSAttributedString.Key: Any] = [:]

        attributes[.font] = style.fonts.current
        attributes[.foregroundColor] = style.colors.current

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 25 - style.fonts.current.pointSize
        paragraphStyle.paragraphSpacing = 16 // 段落间距为16
        attributes[.paragraphStyle] = paragraphStyle
        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: text.utf16.count))

        return attributedString
    }
    /// 解析 <dotline-*> 标签内容
    /// - Parameter rawHTML: 原始的 HTML 字符串
    /// - Returns: 解析后的标签数组
    /// 解析 <dotline-*> 标签内容，仅返回第一个匹配的标签
    /// - Parameter rawHTML: 原始的 HTML 字符串
    /// - Returns: 解析后的标签数组（最多包含一个元素）
    func parseDotlineTags(from rawHTML: String) -> [DotlineTagContent] {
        let tags = ["card-type", "summary"]
        
        for tag in tags {
            let startTag = "<dotline-\(tag)>"
            let endTag = "</dotline-\(tag)>"
            
            if let startRange = rawHTML.range(of: startTag),
               let endRange = rawHTML.range(of: endTag, range: startRange.upperBound..<rawHTML.endIndex) {
                let content = String(rawHTML[startRange.upperBound..<endRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                let tagContent = DotlineTagContent(type: tag, content: content)
                return [tagContent] // 找到第一个匹配的标签后立即返回
            }
        }
        return [] // 如果没有找到任何匹配的标签，返回空数组
    }
}



// 新增的 DotlineCardHandler 类
public class DotlineCardHandler: MarkupHandler {
    
    public var referLoader: ReferLoader?
    public init() {
        
    }
    
    public func canHandle(_ markup: Markup) -> Bool {
        guard let htmlBlock = markup as? HTMLBlock else {
            return false
        }
        let content = htmlBlock.rawHTML.trimmingCharacters(in: .whitespacesAndNewlines)
        return content.hasPrefix("<dotline-card>") || content.hasSuffix("</dotline-card>")
    }
    
    // 处理 markups 数组，并返回 GMarkChunk
    public func handle(_ markups: [Markup], style: Style?) -> GMarkChunk {
        var chunk = GMarkChunk(children: markups, chunkType: .DotlineCard)
        if let style = style {
            chunk.style = style
        }
        
        // 初始化变量以存储解析后的内容
        var cardTitle: String?
        var highlight: String?
        
        // 遍历 markups
        for markup in markups {
            // 如果是 <dotline-card> 开始或结束标签，跳过
            if let htmlBlock = markup as? HTMLBlock {
                let rawHTML = htmlBlock.rawHTML.trimmingCharacters(in: .whitespacesAndNewlines)
                if rawHTML.hasPrefix("<dotline-card>") || rawHTML.hasSuffix("</dotline-card>") {
                    continue // 跳过这些 markup
                }
                if rawHTML.hasPrefix("<dotline-card-title>") && rawHTML.hasSuffix("</dotline-card-title>") {
                    let content = extractContent(from: rawHTML, tag: "dotline-card-title")
                    cardTitle = content
                }
                else if rawHTML.hasPrefix("<dotline-highlight>") && rawHTML.hasSuffix("</dotline-highlight>") {
                    let content = extractContent(from: rawHTML, tag: "dotline-highlight")
                    highlight = content
                }
                else if rawHTML.hasPrefix("<dotline-card-images>") && rawHTML.hasSuffix("</dotline-card-images>") {
                    let content = extractContent(from: rawHTML, tag: "dotline-card-images")
                  
                    let images = parseImageJSONStrings(content)
                    chunk.cardImages = images
                }
            } else if markup is Paragraph,let markSub = markup.child(at: 0) as? InlineHTML, markSub.rawHTML.hasPrefix("<dotline-")  {
                if markSub.rawHTML.hasPrefix("<dotline-highlight>"), markup.childCount > 1,let text = markup.child(at: 1) as? Text {
                    highlight = text.plainText
                } else if markSub.rawHTML.hasPrefix("<dotline-card-title>"), markup.childCount > 1,let text = markup.child(at: 1) as? Text {
                    cardTitle = text.plainText
                } else if markSub.rawHTML.hasPrefix("<dotline-card-images>"), markup.childCount > 1,let text = markup.child(at: 1) as? Text {
                    let images = parseImageJSONStrings(text.plainText)
                    chunk.cardImages = images
                }
            } else {
                var visitor = GMarkupVisitor(style: chunk.style)
                visitor.referLoader = referLoader
                let attributeText = visitor.visit(markup)
                let mutableAttributeText = NSMutableAttributedString(attributedString: chunk.attributeText ?? NSAttributedString())
                mutableAttributeText.append(attributeText)
                chunk.attributeText = mutableAttributeText
            }
        }
        
        // 获取 attributeText 的字符串内容并去除前后的换行符
        if var attributeTextM = chunk.attributeText {
            let trimmedString = attributeTextM.string.trimmingCharacters(in: .newlines)
            // 确定修剪后的字符串在原始 attributeText 中的范围
            if let range = attributeTextM.string.range(of: trimmedString) {
                let nsRange = NSRange(range, in: attributeTextM.string)
                // 从原始 attributeText 中提取修剪后的部分
                let trimmedAttributeText = attributeTextM.attributedSubstring(from: nsRange)
                chunk.attributeText = trimmedAttributeText
            }
        }
      
        // 将解析后的内容赋值给 chunk
        chunk.cardTitle = cardTitle
        chunk.cardHighlight = highlight
        chunk.generatorDotlineCard()
        
        return chunk
    }
    
    /// 从 rawHTML 中提取指定标签的内容
    /// - Parameters:
    ///   - rawHTML: 原始的 HTML 字符串
    ///   - tag: 标签类型，例如 "dotline-summary"
    /// - Returns: 标签内的内容字符串
    private func extractContent(from rawHTML: String, tag: String) -> String {
        let startTag = "<\(tag)>"
        let endTag = "</\(tag)>"
        
        if let startRange = rawHTML.range(of: startTag),
           let endRange = rawHTML.range(of: endTag, range: startRange.upperBound..<rawHTML.endIndex) {
            let content = String(rawHTML[startRange.upperBound..<endRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            return content
        }
        return ""
    }
    
    /// 解析图片
    /// - Parameter jsonString: 要转换的 JSON 字符串
    /// - Returns: 转换后的 [[String: Any]]，如果转换失败则返回 nil
    func parseImageJSONStrings(_ input: String) -> [[String: Any]]? {
        let trim = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if trim.isEmpty {
            return nil
        }
        // 将字符串转换为 Data
        guard let data = trim.data(using: .utf8) else {
            print("无法将字符串转换为 UTF-8 编码的数据。")
            return nil
        }
        
        do {
            // 使用 JSONSerialization 解析数据
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            // 尝试将解析后的对象转换为 [[String: Any]]
            if let jsonArray = jsonObject as? [[String: Any]] {
                return jsonArray
            } else {
                print("JSON 格式不符合预期，无法转换为 [[String: Any]]。")
                return nil
            }
        } catch {
            // 捕获并打印解析错误
            print("解析 JSON 时出错: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    public func handle(_ markup: Markup, style: Style?) -> GMarkChunk {
        var chunk = GMarkChunk(children: [markup], chunkType: .DotlineCard)
        if let style = style {
            chunk.style = style
        }
        // todo
        chunk.itemSize = CGSize(width: style?.maxContainerWidth ?? 0, height: 200) // 根据需要调整高度
        return chunk
    }
}

extension GMarkChunk {
    
    mutating func generatorDotlineCard() {
        generatorCardTextRender()
    }
    
    mutating func generatorCardTextRender() {
        guard let attr = attributeText else {
            return
        }
        
        let builder = MPITextRenderAttributesBuilder()
        builder.attributedText = attr
        builder.maximumNumberOfLines = 0
        let renderAttributes = MPITextRenderAttributes(builder: builder)
        textRender = MPITextRenderer(renderAttributes: renderAttributes, constrainedSize: CGSize(width: style.maxContainerWidth, height: CGFLOAT_MAX))
        
        itemSize = CGSize(width: style.maxContainerWidth, height: textRender?.size().height ?? 0.0)
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
