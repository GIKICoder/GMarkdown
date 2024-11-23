//
//  GMarkupHelper.swift
//  GMarkdownExample
//
//  Created by GIKI on 2024/11/23.
//

import Foundation
import UIKit
import Markdown


// MARK: - Renderer Helper

struct Renderer {
    func drawTagImage(text: String, font: UIFont, width: CGFloat, height: CGFloat, backgroundColor: UIColor, textColor: UIColor, cornerRadius: CGFloat) -> UIImage? {
        let size = CGSize(width: width, height: height)
        let iconName = "detail_quote_ic"
        let iconSize = CGSize(width: 16, height: 16)
        let iconTextSpacing: CGFloat = 2
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Draw background
            let rect = CGRect(origin: .zero, size: size)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            backgroundColor.setFill()
            path.fill()
            
            // Draw icon
            if let icon = UIImage(named: iconName) {
                let iconY = (size.height - iconSize.height) / 2
                let iconRect = CGRect(x: 10, y: iconY, width: iconSize.width, height: iconSize.height)
                icon.draw(in: iconRect)
            }
            
            // Draw text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byTruncatingTail
            paragraphStyle.alignment = .left
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle
            ]
            
            let textX: CGFloat = 10 + iconSize.width + iconTextSpacing
            let availableWidth = size.width - textX - 10
            let textRect = CGRect(
                x: textX,
                y: (size.height - font.lineHeight) / 2,
                width: availableWidth,
                height: font.lineHeight
            )
            
            (text as NSString).draw(in: textRect, withAttributes: attributes)
        }
    }
}


// MARK: - Helper Extensions

extension UIFont {
    var italic: UIFont? {
        return apply(newTraits: .traitItalic)
    }
    
    var bold: UIFont? {
        return apply(newTraits: .traitBold)
    }
    
    func apply(newTraits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        var existingTraits = self.fontDescriptor.symbolicTraits
        existingTraits.insert(newTraits)
        
        guard let newDescriptor = self.fontDescriptor.withSymbolicTraits(existingTraits) else { return nil }
        return UIFont(descriptor: newDescriptor, size: self.pointSize)
    }
}

extension NSMutableAttributedString.Key {
    static let listDepth = NSAttributedString.Key("ListDepth")
    static let quoteDepth = NSAttributedString.Key("QuoteDepth")
}

extension NSMutableAttributedString {
    func addAttribute(_ name: NSAttributedString.Key, value: Any) {
        addAttribute(name, value: value, range: NSRange(location: 0, length: length))
    }
    
    func addAttributes(_ attrs: [NSAttributedString.Key: Any]) {
        addAttributes(attrs, range: NSRange(location: 0, length: length))
    }
    
    func applyEmphasis() {
        enumerateAttribute(.font, in: NSRange(location: 0, length: length), options: []) { value, range, _ in
            guard let font = value as? UIFont else { return }
            if let italicFont = font.italic {
                addAttribute(.font, value: italicFont, range: range)
            }
        }
    }
    
    func applyStrong() {
        enumerateAttribute(.font, in: NSRange(location: 0, length: length), options: []) { value, range, _ in
            guard let font = value as? UIFont else { return }
            if let boldFont = font.bold {
                addAttribute(.font, value: boldFont, range: range)
            }
        }
    }
}

extension NSAttributedString {
    static func singleNewline(withStyle style: Style) -> NSAttributedString {
        return NSAttributedString(string: "\n", attributes: [.font: style.fonts.current])
    }
    
    static func doubleNewline(withStyle style: Style) -> NSAttributedString {
        return NSAttributedString(string: "\n\n", attributes: [.font: style.fonts.current])
    }
}

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
        let siblingIndex = indexInParent
        guard let parent = parent, siblingIndex < parent.childCount - 1 else { return false }
        if let nextSibling = parent.child(at: siblingIndex + 1) {
            return !isSplitPoint(nextSibling)
        }
        return false
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
            if paragraph.childCount == 3,let inlineHTML = paragraph.child(at: 0) as? InlineHTML, inlineHTML.plainText == "<LaTex>" {
                return true
            }
            return false
        default:
            return false
        }
    }
}

