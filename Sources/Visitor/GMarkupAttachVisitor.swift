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
    
    // 插件管理器
    private let pluginManager: GMarkupPluginManager
    private let style: Style
    // 初始化方法
    public init(style: Style = MarkdownStyle.defaultStyle(),pluginManager: GMarkupPluginManager = GMarkupPluginManager.shared) {
        self.style = style
        self.pluginManager = pluginManager
    }
    
    public mutating func defaultVisit(_ markup: Markup) -> NSAttributedString {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(markup, visitor: &self) {
            return pluginResult
        }
        let result = NSMutableAttributedString()
        for child in markup.children {
            result.append(visit(child))
        }
        return result
    }
    
    public mutating func visit(_ markup: Markup) -> Result {
        return markup.accept(&self)
    }
    
    public mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> Result {
        return MarkdownBlockQuoteProcessor.processBlockQuote(blockQuote,style: style, visitor:self)
    }
    
    public mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(codeBlock, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return defaultVisit(codeBlock)
    }
    
    public mutating func visitCustomBlock(_ customBlock: CustomBlock) -> Result {
        return defaultVisit(customBlock)
    }
    
    public mutating func visitDocument(_ document: Document) -> Result {
        return defaultVisit(document)
    }
    
    public mutating func visitHeading(_ heading: Heading) -> Result {
        let attributedString = defaultVisitForMutable(heading)
        MarkdownStyleProcessor.applyHeadingStyle(to: attributedString, heading: heading, style: style)
        MarkdownStyleProcessor.appendNewlineIfNeeded(for: heading, to: attributedString, style: style)
        return attributedString
    }
    
    public mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> Result {
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
        let attributedString = defaultVisitForMutable(listItem)
        MarkdownStyleProcessor.appendNewlineIfNeeded(for: listItem, to: attributedString, style: style)
        return attributedString
    }
    
    public mutating func visitOrderedList(_ orderedList: OrderedList) -> Result {
        var visitor: any MarkupVisitor = self
        let result = MarkdownListProcessor.processOrderedList(
            orderedList,
            style: style,
            visitor: &visitor
        )
        return result
    }
    
    public mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> Result {
        var visitor: any MarkupVisitor = self
        let result = MarkdownListProcessor.processUnorderedList(
            unorderedList,
            style: style,
            visitor: &visitor
        )
        return result
    }
    public mutating func visitParagraph(_ paragraph: Paragraph) -> Result {
        let attributedString = defaultVisitForMutable(paragraph)
        MarkdownStyleProcessor.appendNewlineIfNeeded(for: paragraph, to: attributedString, style: style)
        return attributedString
    }
    
    public mutating func visitBlockDirective(_ blockDirective: BlockDirective) -> Result {
        return defaultVisit(blockDirective)
    }
    
    public mutating func visitInlineCode(_ inlineCode: InlineCode) -> Result {
        let attributedString = createDefaultAttributedString(from: inlineCode.code)
        MarkdownStyleProcessor.applyInlineCodeStyle(to: attributedString, style: style)
        return attributedString
    }
    
    public mutating func visitCustomInline(_ customInline: CustomInline) -> Result {
        return defaultVisit(customInline)
    }
    
    public mutating func visitEmphasis(_ emphasis: Emphasis) -> Result {
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
        return defaultVisit(inlineHTML)
    }
    
    public mutating func visitLineBreak(_ lineBreak: LineBreak) -> Result {
        return createDefaultAttributedString(from: lineBreak.plainText)
    }
    
    public mutating func visitLink(_ link: Link) -> Result {
        let attributedString = defaultVisitForMutable(link)
        MarkdownStyleProcessor.applyLinkStyle(to: attributedString,
                                              destination: link.destination,
                                              linkColor: style.colors.link,
                                              useMPTextKit: style.useMPTextKit)
        return attributedString
    }
    
    public mutating func visitSoftBreak(_ softBreak: SoftBreak) -> Result {
        return NSAttributedString.singleNewline(withStyle: style)
    }
    
    public mutating func visitStrong(_ strong: Strong) -> Result {
        let attributedString = defaultVisitForMutable(strong)
        MarkdownStyleProcessor.applyBoldFont(to: attributedString)
        return attributedString
    }
    
    public mutating func visitText(_ text: Text) -> Result {
        return createDefaultAttributedString(from: text.plainText)
    }
    
    public mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> Result {
        let attributedString = defaultVisitForMutable(strikethrough)
        attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue)
        return attributedString
    }
    
    public mutating func visitTable(_ table: Table) -> Result {
        // 尝试使用插件处理
        if let pluginResult = pluginManager.handle(table, visitor: &self) {
            return pluginResult
        }
        // 使用默认处理
        return defaultVisit(table)
    }
    public mutating func visitTableHead(_ tableHead: Table.Head) -> Result {
        return defaultVisit(tableHead)
    }
    public mutating func visitTableBody(_ tableBody: Table.Body) -> Result {
        return defaultVisit(tableBody)
    }
    public mutating func visitTableRow(_ tableRow: Table.Row) -> Result {
        return defaultVisit(tableRow)
    }
    public mutating func visitTableCell(_ tableCell: Table.Cell) -> Result {
        return defaultVisit(tableCell)
    }
    public mutating func visitSymbolLink(_ symbolLink: SymbolLink) -> Result {
        return defaultVisit(symbolLink)
    }
    public mutating func visitInlineAttributes(_ attributes: InlineAttributes) -> Result {
        return defaultVisit(attributes)
    }
    public mutating func visitDoxygenParameter(_ doxygenParam: DoxygenParameter) -> Result {
        return defaultVisit(doxygenParam)
    }
    public mutating func visitDoxygenReturns(_ doxygenReturns: DoxygenReturns) -> Result {
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
