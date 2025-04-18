//
//  AttributedStringHelper.swift
//  GMarkdown
//
//  Created by GIKI on 2025/4/18.
//

import UIKit


public extension NSTextAttachment {

    convenience init(image: UIImage, size: CGSize? = nil) {
        self.init(data: nil, ofType: nil)

        self.image = image
        if let size = size {
            self.bounds = CGRect(origin: .zero, size: size)
        }
    }

}

public extension NSAttributedString {

    func insertingAttachment(_ attachment: NSTextAttachment, at index: Int, with paragraphStyle: NSParagraphStyle? = nil) -> NSAttributedString {
        let copy = self.mutableCopy() as! NSMutableAttributedString
        copy.insertAttachment(attachment, at: index, with: paragraphStyle)

        return copy.copy() as! NSAttributedString
    }

    func addingAttributes(_ attributes: [NSAttributedString.Key : Any]) -> NSAttributedString {
        let copy = self.mutableCopy() as! NSMutableAttributedString
        copy.addAttributes(attributes)

        return copy.copy() as! NSAttributedString
    }

}

extension NSAttributedString {
    static func singleNewline(withStyle style: Style) -> NSAttributedString {
        return NSAttributedString(string: "\n", attributes: [.font: style.fonts.current])
    }
    
    static func doubleNewline(withStyle style: Style) -> NSAttributedString {
        return NSAttributedString(string: "\n", attributes: [.font: style.fonts.current])
    }
}


public extension NSMutableAttributedString {

    func insertAttachment(_ attachment: NSTextAttachment, at index: Int, with paragraphStyle: NSParagraphStyle? = nil) {
        let plainAttachmentString = NSAttributedString(attachment: attachment)

        if let paragraphStyle = paragraphStyle {
            let attachmentString = plainAttachmentString
                .addingAttributes([ .paragraphStyle : paragraphStyle ])
            let separatorString = NSAttributedString(string: .paragraphSeparator)

            // Surround the attachment string with paragraph separators, so that the paragraph style is only applied to it
            let insertion = NSMutableAttributedString()
            insertion.append(separatorString)
            insertion.append(attachmentString)
            insertion.append(separatorString)

            self.insert(insertion, at: index)
        } else {
            self.insert(plainAttachmentString, at: index)
        }
    }

}

public extension String {
    static let paragraphSeparator = "\u{2029}"
}

extension NSMutableAttributedString.Key {
    static let listDepth = NSAttributedString.Key("ListDepth")
    static let quoteDepth = NSAttributedString.Key("QuoteDepth")
    static let indent = NSAttributedString.Key("Indent")
    static let blockQuote = NSAttributedString.Key("BlockQuote")
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

