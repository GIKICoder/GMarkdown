//
//  GMarkupPlugin.swift
//  GMarkdown
//
//  Created by GIKI on 2025/7/5.
//

import Foundation
import Markdown
import UIKit
import SwiftMath

/// 插件协议，用于处理不同类型的Markup元素
public protocol GMarkupPlugin {
    /// 插件标识符
    var identifier: String { get }
    
    /// 插件是否可以处理指定的Markup类型
    func canHandle(_ markup: Markup) -> Bool
    
    /// 处理Markup并返回AttributedString
    func handle(_ markup: Markup, visitor: inout GMarkupAttachVisitor) -> NSAttributedString?
}


/// 默认代码块插件实现
public class DefaultCodePlugin: GMarkupPlugin {
    public var identifier: String { "default.code" }
    
    public func canHandle(_ markup: Markup) -> Bool {
        return markup is CodeBlock
    }
    
    public func handle(_ markup: Markup, visitor: inout GMarkupAttachVisitor) -> NSAttributedString? {
        guard let codeBlock = markup as? CodeBlock else { return nil }
        return handleCodeBlock(codeBlock, visitor: &visitor)
    }
    
    public func handleCodeBlock(_ codeBlock: CodeBlock, visitor: inout GMarkupAttachVisitor) -> NSAttributedString? {
        let style = visitor.visitorStyle
        let code = codeBlock.code.trimmingCharacters(in: .whitespacesAndNewlines)
        let language = codeBlock.language
        if style.codeBlockStyle.useHighlight {
            if let highlighted = GMarkCodeHighlight.shared.generateAttributeText(code, language: language ?? ""),
               !highlighted.string.hasPrefix("undefined") {
                let attributed = NSMutableAttributedString(attributedString: highlighted)
                attributed.addAttribute(.font, value: style.codeBlockStyle.font)
                let attachment = MarkdownAttachment(viewProvider: MDCodeAttachedProvider(markup: codeBlock, style: style, attributedText: attributed))
                return NSAttributedString(attachment: attachment)
            }
        }
        let attributedString = MarkdownStyleProcessor.buildDefaultAttributedString(from: code, style: style)
        attributedString.addAttribute(.font, value: style.codeBlockStyle.font)
        attributedString.addAttribute(.foregroundColor, value: style.codeBlockStyle.foregroundColor)
        let attachment = MarkdownAttachment(viewProvider: MDCodeAttachedProvider(markup: codeBlock, style: style, attributedText: attributedString))
        return NSAttributedString(attachment: attachment)
    }
}

/// 默认表格插件实现
public class DefaultTablePlugin: GMarkupPlugin {
    public var identifier: String { "default.table" }
    
    public func canHandle(_ markup: Markup) -> Bool {
        return markup is Table
    }
    
    public func handle(_ markup: Markup, visitor: inout GMarkupAttachVisitor) -> NSAttributedString? {
        guard let table = markup as? Table else { return nil }
        return handleTable(table, visitor: &visitor)
    }
    
    public func handleTable(_ table: Table, visitor: inout GMarkupAttachVisitor) -> NSAttributedString? {
        let result = NSMutableAttributedString()
        
//        // 处理表头
//        if let head = table.head {
//            result.append(visitor.visitTableHead(head))
//        }
//        
//        // 处理表体
//        if let body = table.body {
//            result.append(visitor.visitTableBody(body))
//        }
        
        return result
    }
}

/// 默认图片插件实现
public class DefaultImagePlugin: GMarkupPlugin {
    public var identifier: String { "default.image" }
    
    public func canHandle(_ markup: Markup) -> Bool {
        return markup is Image
    }
    
    public func handle(_ markup: Markup, visitor: inout GMarkupAttachVisitor) -> NSAttributedString? {
        guard let image = markup as? Image else { return nil }
        return handleImage(image, visitor: &visitor)
    }
    
    public func handleImage(_ image: Image, visitor: inout GMarkupAttachVisitor) -> NSAttributedString? {
        guard image.source != nil else {
            return nil
        }
        let imageProvider = MDAsyncImageAttachedProvider(markup: image, style: visitor.visitorStyle)
        let attachment = MarkdownAttachment(viewProvider: imageProvider)
        return NSAttributedString(attachment: attachment)
    }
}

/// 默认HTML块插件实现
public class DefaultHTMLBlockPlugin: GMarkupPlugin {
    public var identifier: String { "default.htmlblock" }
    
    public func canHandle(_ markup: Markup) -> Bool {
        return markup is HTMLBlock
    }
    
    public func handle(_ markup: Markup, visitor: inout GMarkupAttachVisitor) -> NSAttributedString? {
        guard let htmlBlock = markup as? HTMLBlock else { return nil }
        return handleHTMLBlock(htmlBlock, visitor: &visitor)
    }
    
    public func handleHTMLBlock(_ htmlBlock: HTMLBlock, visitor: inout GMarkupAttachVisitor) -> NSAttributedString? {
        let style = visitor.visitorStyle
        let rawHTML = htmlBlock.rawHTML.trimmingCharacters(in: .whitespacesAndNewlines)
        let result = MarkdownStyleProcessor.buildDefaultAttributedString(from: rawHTML, style: style)
        MarkdownStyleProcessor.appendBreakIfNeeded(for: htmlBlock, to: result, style: style)
        return result
    }
}

/// 默认内联HTML插件实现
public class DefaultInlineHTMLPlugin: GMarkupPlugin {
    public var identifier: String { "default.inlinehtml" }
    
    public func canHandle(_ markup: Markup) -> Bool {
        return markup is InlineHTML
    }
    
    public func handle(_ markup: Markup, visitor: inout GMarkupAttachVisitor) -> NSAttributedString? {
        guard let inlineHTML = markup as? InlineHTML else { return nil }
        return handleInlineHTML(inlineHTML, visitor: &visitor)
    }
    
    public func handleInlineHTML(_ inlineHTML: InlineHTML, visitor: inout GMarkupAttachVisitor) -> NSAttributedString? {
        let style = visitor.visitorStyle
        let rawHTML = inlineHTML.rawHTML.trimmingCharacters(in: .whitespacesAndNewlines)
        let result = MarkdownStyleProcessor.buildDefaultAttributedString(from: rawHTML, style: style)
        MarkdownStyleProcessor.appendBreakIfNeeded(for: inlineHTML, to: result, style: style)
        return result
    }
}
