//
//  File.swift
//  GMarkdown
//
//  Created by 巩柯 on 2025/4/18.
//

import Foundation
import Markdown

public struct GMarkupStringifier: MarkupVisitor {
    public typealias Result = String
    
    public init() {}
    
    public mutating func defaultVisit(_ markup: Markup) -> String {
        var result = ""
        for child in markup.children {
            result += visit(child)
        }
        return result
    }
    
    public mutating func visitDocument(_ document: Document) -> String {
        return defaultVisit(document)
    }
    
    public mutating func visitText(_ text: Text) -> String {
        // 只替换结尾的单个反斜杠
        if text.string.hasSuffix(" \\") {
            let withoutSlash = text.string.dropLast(2) // 移除最后的 " \"
            return withoutSlash + " \\\\"
        }
        return text.string
    }
    
    public mutating func visitParagraph(_ paragraph: Paragraph) -> String {
        return defaultVisit(paragraph) + "\n\n"
    }
    
    public mutating func visitHeading(_ heading: Heading) -> String {
        return defaultVisit(heading)
    }
    
    public mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> String {
        return codeBlock.code
    }
    
    public mutating func visitInlineCode(_ inlineCode: InlineCode) -> String {
        return inlineCode.code
    }
    
    public mutating func visitLink(_ link: Link) -> String {
        return defaultVisit(link)
    }
    
    public mutating func visitImage(_ image: Image) -> String {
        return defaultVisit(image)
    }
    
    public mutating func visitEmphasis(_ emphasis: Emphasis) -> String {
        return defaultVisit(emphasis)
    }
    
    public mutating func visitStrong(_ strong: Strong) -> String {
        return defaultVisit(strong)
    }
    
    public mutating func visitLineBreak(_ lineBreak: LineBreak) -> String {
        return "\n"
    }
    
    public mutating func visitSoftBreak(_ softBreak: SoftBreak) -> String {
        return "\n"
    }
    
    public mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> String {
        return defaultVisit(blockQuote)
    }
    
    public mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> String {
        return defaultVisit(unorderedList)
    }
    
    public mutating func visitOrderedList(_ orderedList: OrderedList) -> String {
        return defaultVisit(orderedList)
    }
    
    public mutating func visitListItem(_ listItem: ListItem) -> String {
        return defaultVisit(listItem)
    }
    
    public mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> String {
        return defaultVisit(strikethrough)
    }
}
