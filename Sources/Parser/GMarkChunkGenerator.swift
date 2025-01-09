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
        TableMarkupHandler(),
        CodeBlockMarkupHandler(),
        BlockQuoteMarkupHandler(),
        ThematicBreakHandler(),
        ImageHandler(),
//        LaTexHandler(),
    ]) {
        self.handlers = handlers
    }
    
    public func generateChunks(from markups: [Markup]) -> [GMarkChunk] {
        var chunks: [GMarkChunk] = []
        var currentChunk = GMarkChunk(chunkType: .Text)
        if let chunkStyle = style {
            currentChunk.style = chunkStyle
        }
        for markup in markups {
            if let handler = handlers.first(where: { $0.canHandle(markup) }) {
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
        var style = style
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
