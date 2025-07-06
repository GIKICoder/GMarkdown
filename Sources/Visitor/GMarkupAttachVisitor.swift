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

    // 初始化方法
    public init(pluginManager: GMarkupPluginManager = GMarkupPluginManager.shared) {
        self.pluginManager = pluginManager
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
    public mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> Result {
        return defaultVisit(blockQuote)
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
        return defaultVisit(heading)
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
        return defaultVisit(listItem)
    }
    public mutating func visitOrderedList(_ orderedList: OrderedList) -> Result {
        return defaultVisit(orderedList)
    }
    public mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> Result {
        return defaultVisit(unorderedList)
    }
    public mutating func visitParagraph(_ paragraph: Paragraph) -> Result {
        return defaultVisit(paragraph)
    }
    public mutating func visitBlockDirective(_ blockDirective: BlockDirective) -> Result {
        return defaultVisit(blockDirective)
    }
    public mutating func visitInlineCode(_ inlineCode: InlineCode) -> Result {
        return defaultVisit(inlineCode)
    }
    public mutating func visitCustomInline(_ customInline: CustomInline) -> Result {
        return defaultVisit(customInline)
    }
    public mutating func visitEmphasis(_ emphasis: Emphasis) -> Result {
        return defaultVisit(emphasis)
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
        return defaultVisit(lineBreak)
    }
    public mutating func visitLink(_ link: Link) -> Result {
        return defaultVisit(link)
    }
    public mutating func visitSoftBreak(_ softBreak: SoftBreak) -> Result {
        return defaultVisit(softBreak)
    }
    public mutating func visitStrong(_ strong: Strong) -> Result {
        return defaultVisit(strong)
    }
    public mutating func visitText(_ text: Text) -> Result {
        return defaultVisit(text)
    }
    public mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> Result {
        return defaultVisit(strikethrough)
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
