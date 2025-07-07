//
//  GMarkupAttachVisitor.swift
//  GMarkdown
//
//  Created by GIKI on 2025/4/18.
//

import Foundation
import Markdown
import UIKit
#if canImport(MPITextKit)
import MPITextKit
#endif
import SwiftMath

public struct GMarkupAttachVisitor: MarkupVisitor {
    public typealias Result = NSAttributedString
    
    public var imageLoader: ImageLoader?
    // 插件管理器
    private let pluginManager: GMarkupPluginManager
    private let style: Style
    
    // 初始化方法
    public init(style: Style = MarkdownStyle.defaultStyle(), pluginManager: GMarkupPluginManager = GMarkupPluginManager.shared) {
        self.style = style
        self.pluginManager = pluginManager
    }
    
    // 添加公共访问器
    public var visitorStyle: Style {
        return style
    }
    
    
    public mutating func defaultVisit(_ markup: Markup) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for child in markup.children {
            result.append(visit(child))
        }
        return result
    }
    
    public mutating func visit(_ markup: Markup) -> Result {
        return markup.accept(&self)
    }
    
    // MARK: - Block Elements
    
    public mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(blockQuote, visitor: &self) {
            return pluginResult
        }
        let result = MarkdownBlockQuoteProcessor.processBlockQuote(blockQuote, style: style, visitor: self)
        MarkdownStyleProcessor.appendBreakIfNeeded(for: blockQuote, to: result, style: style)
        return result
    }
    
    public mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(codeBlock, visitor: &self) {
            return pluginResult
        }
        let attributed = createDefaultAttributedString(from: codeBlock.code)
        attributed.addAttribute(.font, value: style.codeBlockStyle.font)
        attributed.addAttribute(.foregroundColor, value: style.codeBlockStyle.foregroundColor)
        return attributed
    }
    
    public mutating func visitCustomBlock(_ customBlock: CustomBlock) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(customBlock, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return defaultVisit(customBlock)
    }
    
    public mutating func visitDocument(_ document: Document) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(document, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return defaultVisit(document)
    }
    
    public mutating func visitHeading(_ heading: Heading) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(heading, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        let attributedString = defaultVisitForMutable(heading)
        MarkdownStyleProcessor.applyHeadingStyle(to: attributedString, heading: heading, style: style)
        MarkdownStyleProcessor.appendBreakIfNeeded(for: heading, to: attributedString, style: style)
        return attributedString
    }
    
    public mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(thematicBreak, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return defaultVisit(thematicBreak)
    }
    
    public mutating func visitHTMLBlock(_ html: HTMLBlock) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(html, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return defaultVisit(html)
    }
    
    public mutating func visitListItem(_ listItem: ListItem) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(listItem, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        let attributedString = defaultVisitForMutable(listItem)
        MarkdownStyleProcessor.appendBreakIfNeeded(for: listItem, to: attributedString, style: style)
        return attributedString
    }
    
    public mutating func visitOrderedList(_ orderedList: OrderedList) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(orderedList, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        var visitor: any MarkupVisitor = self
        let result = MarkdownListProcessor.processOrderedList(
            orderedList,
            style: style,
            visitor: &visitor
        )
        MarkdownStyleProcessor.appendBreakIfNeeded(for: orderedList, to: result, style: style)
        return result
    }
    
    public mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(unorderedList, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        var visitor: any MarkupVisitor = self
        let result = MarkdownListProcessor.processUnorderedList(
            unorderedList,
            style: style,
            visitor: &visitor
        )
        MarkdownStyleProcessor.appendBreakIfNeeded(for: unorderedList, to: result, style: style)
        return result
    }
    
    public mutating func visitParagraph(_ paragraph: Paragraph) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(paragraph, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        let attributedString = defaultVisitForMutable(paragraph)
        MarkdownStyleProcessor.appendBreakIfNeeded(for: paragraph, to: attributedString, style: style)
        return attributedString
    }
    
    public mutating func visitBlockDirective(_ blockDirective: BlockDirective) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(blockDirective, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return defaultVisit(blockDirective)
    }
    
    // MARK: - Inline Elements
    
    public mutating func visitInlineCode(_ inlineCode: InlineCode) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(inlineCode, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        let attributedString = createDefaultAttributedString(from: inlineCode.code)
        MarkdownStyleProcessor.applyInlineCodeStyle(to: attributedString, style: style)
        return attributedString
    }
    
    public mutating func visitCustomInline(_ customInline: CustomInline) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(customInline, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return defaultVisit(customInline)
    }
    
    public mutating func visitEmphasis(_ emphasis: Emphasis) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(emphasis, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        let attributedString = defaultVisitForMutable(emphasis)
        MarkdownStyleProcessor.applyItalicFont(to: attributedString)
        return attributedString
    }
    
    public mutating func visitImage(_ image: Image) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(image, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return defaultVisit(image)
    }
    
    public mutating func visitInlineHTML(_ inlineHTML: InlineHTML) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(inlineHTML, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return createDefaultAttributedString(from: inlineHTML.plainText)
    }
    
    public mutating func visitLineBreak(_ lineBreak: LineBreak) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(lineBreak, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return createDefaultAttributedString(from: lineBreak.plainText)
    }
    
    public mutating func visitLink(_ link: Link) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(link, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        let attributedString = defaultVisitForMutable(link)
        MarkdownStyleProcessor.applyLinkStyle(to: attributedString,
                                              destination: link.destination,
                                              linkColor: style.colors.link,
                                              useMPTextKit: style.useMPTextKit)
        return attributedString
    }
    
    public mutating func visitSoftBreak(_ softBreak: SoftBreak) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(softBreak, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return NSAttributedString.singleNewline(withStyle: style)
    }
    
    public mutating func visitStrong(_ strong: Strong) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(strong, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        let attributedString = defaultVisitForMutable(strong)
        MarkdownStyleProcessor.applyBoldFont(to: attributedString)
        return attributedString
    }
    
    public mutating func visitText(_ text: Text) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(text, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return createDefaultAttributedString(from: text.plainText)
    }
    
    public mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(strikethrough, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        let attributedString = defaultVisitForMutable(strikethrough)
        attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue)
        return attributedString
    }
    
    // MARK: - Table Elements
    
    public mutating func visitTable(_ table: Table) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(table, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return defaultVisit(table)
    }
    
    public mutating func visitTableHead(_ tableHead: Table.Head) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(tableHead, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return defaultVisit(tableHead)
    }
    
    public mutating func visitTableBody(_ tableBody: Table.Body) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(tableBody, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return defaultVisit(tableBody)
    }
    
    public mutating func visitTableRow(_ tableRow: Table.Row) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(tableRow, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return defaultVisit(tableRow)
    }
    
    public mutating func visitTableCell(_ tableCell: Table.Cell) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(tableCell, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return defaultVisit(tableCell)
    }
    
    // MARK: - Other Elements
    
    public mutating func visitSymbolLink(_ symbolLink: SymbolLink) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(symbolLink, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return defaultVisit(symbolLink)
    }
    
    public mutating func visitInlineAttributes(_ attributes: InlineAttributes) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(attributes, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return defaultVisit(attributes)
    }
    
    public mutating func visitDoxygenParameter(_ doxygenParam: DoxygenParameter) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(doxygenParam, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return defaultVisit(doxygenParam)
    }
    
    public mutating func visitDoxygenReturns(_ doxygenReturns: DoxygenReturns) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(doxygenReturns, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return defaultVisit(doxygenReturns)
    }
}

// MARK: - Child Processing
extension GMarkupAttachVisitor {
    
    private mutating func defaultVisitForMutable(_ markup: Markup) -> NSMutableAttributedString {
        let result = NSMutableAttributedString()
        for child in markup.children {
            result.append(visit(child))
        }
        return result
    }
    
    private func createDefaultAttributedString(from text: String) -> NSMutableAttributedString {
        return MarkdownStyleProcessor.buildDefaultAttributedString(from: text, style: style)
    }
}
