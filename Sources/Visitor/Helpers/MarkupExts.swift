//
//  MarkupExts.swift
//  GMarkdown
//
//  Created by 巩柯 on 2025/7/3.
//

import Markdown

extension ListItemContainer {
    var listDepth: Int {
        var depth = 0
        var current = parent
        while let currentElement = current {
            if currentElement is ListItemContainer {
                depth += 1
            }
            current = currentElement.parent
        }
        return depth
    }
}

extension BlockQuote {
    var quoteDepth: Int {
        var depth = 0
        var current = parent
        while let currentElement = current {
            if currentElement is BlockQuote {
                depth += 1
            }
            current = currentElement.parent
        }
        return depth
    }
}

extension Markup {
    
    var hasSuccessor: Bool {
        guard let childCount = parent?.childCount else { return false }
        return indexInParent < childCount - 1
    }
    
    var hasSuccessorForSplit: Bool {
        let siblingIndex = indexInParent
        guard let parent = parent, siblingIndex < parent.childCount - 1 else { return false }
        guard let nextSibling = parent.child(at: siblingIndex + 1) else { return false }
        return !isSplitPoint(nextSibling)
    }
    
    var isContainedInList: Bool {
        var current = parent
        while let currentElement = current {
            if currentElement is ListItemContainer {
                return true
            }
            current = currentElement.parent
        }
        return false
    }
    
    var subTag: String? {
        let siblingIndex = indexInParent
        guard let parent = parent, siblingIndex < parent.childCount - 1 else { return nil }
        let nextSibling = parent.child(at: siblingIndex + 1)
        if let inlineHTML = nextSibling as? InlineHTML, inlineHTML.plainText == "<sup>",
           let tagText = parent.child(at: siblingIndex + 2) as? Text {
            return tagText.plainText
        }
        return nil
    }
    
    func isSplitPoint(_ item: Markup) -> Bool {
        switch item {
        case is Table, is CodeBlock, is ThematicBreak, is Image:
            return true
        case let paragraph as Paragraph:
            if paragraph.child(at: 0) is Image { return true }
            if let inlineHTML = paragraph.child(at: 0) as? InlineHTML, inlineHTML.plainText == "<LaTex>" {
                return true
            }
            return false
        default:
            return false
        }
    }
}
