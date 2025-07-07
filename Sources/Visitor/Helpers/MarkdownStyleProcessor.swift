//
//  MarkdownStyleProcessor.swift
//  GMarkdown
//
//  Created by 巩柯 on 2025/7/3.
//

import UIKit
import Markdown
#if canImport(MPITextKit)
import MPITextKit
#endif

public struct MarkdownStyleProcessor {
    
    // MARK: - Building
    
    public static func buildDefaultAttributedString(from text: String, style: Style) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[.font] = style.fonts.current
        attributes[.foregroundColor] = style.colors.current
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 25 - style.fonts.current.pointSize
        paragraphStyle.paragraphSpacing = 16
        
        let isRTL = TextDirectionDetector.isRTLLanguage(text: text)
        paragraphStyle.baseWritingDirection = isRTL ? .rightToLeft : .leftToRight
        paragraphStyle.alignment = isRTL ? .right : .left
        attributes[.paragraphStyle] = paragraphStyle
        
        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: text.utf16.count))
        
        return attributedString
    }
    
    public static func appendSplitBreakIfNeeded(for markup: Markup,
                                            to attributedString: NSMutableAttributedString,
                                            style: Style) {
        if markup.hasSuccessorForSplit {
            let newline = markup.isContainedInList ?
                NSAttributedString.singleNewline(withStyle: style) :
                NSAttributedString.singleNewline(withStyle: style)
            attributedString.append(newline)
        }
    }
    
    public static func appendBreakIfNeeded(for markup: Markup,
                                            to attributedString: NSMutableAttributedString,
                                            style: Style) {
        if markup.hasSuccessor {
            let newline = markup.isContainedInList ?
                NSAttributedString.singleNewline(withStyle: style) :
                NSAttributedString.singleNewline(withStyle: style)
            attributedString.append(newline)
        }
    }
    
    // MARK: - Font Styles
    
    public static func applyItalicFont(to attributedString: NSMutableAttributedString) {
        attributedString.enumerateAttribute(.font, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, _ in
            guard let font = value as? UIFont else { return }
            if let italicFont = font.italic {
                attributedString.addAttribute(.font, value: italicFont, range: range)
            }
        }
    }
    
    public static func applyBoldFont(to attributedString: NSMutableAttributedString) {
        attributedString.enumerateAttribute(.font, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, _ in
            guard let font = value as? UIFont else { return }
            if let boldFont = font.bold {
                attributedString.addAttribute(.font, value: boldFont, range: range)
            }
        }
    }
    
    // MARK: - Link Styles
    
    public static func applyLinkStyle(to attributedString: NSMutableAttributedString,
                                      destination: String?,
                                      linkColor: UIColor,
                                      useMPTextKit: Bool) {
        guard let destination = destination, let url = URL(string: destination) else { return }
        attributedString.addAttribute(.foregroundColor, value: linkColor)
        if useMPTextKit {
            let mpiLink = MPITextLink()
            mpiLink.value = url as any NSObjectProtocol
            attributedString.addAttribute(.MPILink, value: mpiLink)
        } else {
            attributedString.addAttribute(.link, value: url)
        }
    }
    
    // MARK: - Code Styles
    
    public static func applyInlineCodeStyle(to attributedString: NSMutableAttributedString,
                                            style: Style) {
        attributedString.addAttribute(.foregroundColor, value: style.colors.inlineCodeForeground)
        attributedString.addAttribute(.font, value: style.fonts.inlineCodeFont)
        
        if style.useMPTextKit {
            let background = MPITextBackground(fill: style.colors.inlineCodeBackground, cornerRadius: 4)
            background.insets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: -2)
            attributedString.addAttribute(.MPIBackground, value: background)
        } else {
            attributedString.addAttribute(.backgroundColor, value: style.colors.inlineCodeBackground)
        }
    }
    
    // MARK: - Heading Styles
    
    public static func applyHeadingStyle(to attributedString: NSMutableAttributedString,
                                         heading: Heading,
                                         style: Style) {
        let font = style.font(forHeading: heading)
        let color = style.color(forHeading: heading)
        attributedString.addAttribute(.foregroundColor, value: color)
        attributedString.addAttribute(.font, value: font)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 25 - font.pointSize
        paragraphStyle.paragraphSpacing = 16
        let isRTL = TextDirectionDetector.isRTLLanguage(text: attributedString.string)
        paragraphStyle.baseWritingDirection = isRTL ? .rightToLeft : .leftToRight
        paragraphStyle.alignment = isRTL ? .right : .left
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle)
    }
    
    // MARK: - Quote Styles
    
    public static func applyQuoteStyle(to attributedString: NSMutableAttributedString,
                                       style: Style) {
        if style.useMPTextKit {
            let background = MPITextBackground(fill: style.blockquoteStyle.backgroundColor, cornerRadius: 1)
            background.borderEdges = .left
            background.borderColor = style.blockquoteStyle.borderColor
            background.borderWidth = style.blockquoteStyle.borderWidth
            attributedString.addAttribute(.MPIBlockBackground, value: background)
        } else {
            attributedString.addAttribute(.backgroundColor, value: style.blockquoteStyle.backgroundColor)
        }
    }
    
    // MARK: - Image Processing
    
    public static func createImageAttributedString(source: String,
                                                  style: Style,
                                                  imageLoader: ImageLoader?) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        let imageView = UIImageView()
        imageView.backgroundColor = style.imageStyle.backgroundColor
        imageView.layer.cornerRadius = style.imageStyle.cornerRadius
        imageView.clipsToBounds = true
        imageView.contentMode = style.imageStyle.contentMode
        
        imageLoader?.loadImage(from: source, into: imageView)
        
        let attachment = MPITextAttachment()
        attachment.content = imageView
        attachment.contentSize = style.imageStyle.size
        attachment.contentInsets = style.imageStyle.padding
        attachment.verticalAligment = .center
        
        let attrString = NSMutableAttributedString(attachment: attachment)
        if let url = URL(string: source) {
            attrString.addAttribute(.link, value: url)
            let mpiLink = MPITextLink()
            mpiLink.value = url as any NSObjectProtocol
            attrString.addAttribute(.MPILink, value: mpiLink)
        }
        
        result.append(attrString)
        return result
    }
}
