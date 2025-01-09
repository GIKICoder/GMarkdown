//
//  GMarkStyle.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/25.
//

import Foundation
import Markdown
import UIKit

///  Font Style
public protocol FontStyle {
    /// Current Font
    var current: UIFont { get set }

    /// H1 Font
    var h1: UIFont { get set }

    /// H2 Font
    var h2: UIFont { get set }

    /// H3 Font
    var h3: UIFont { get set }

    /// H4 Font
    var h4: UIFont { get set }

    /// H5 Font
    var h5: UIFont { get set }

    /// H6 Font
    var h6: UIFont { get set }

    /// Paragraph Font
    var paragraph: UIFont { get set }

    var inlineCodeFont: UIFont { get set }
    
    var quoteFont: UIFont { get set }
}

/// Color style.
public protocol ColorStyle {
    /// Current foreground UIColor
    var current: UIColor { get set }

    /// H1 foreground UIColor
    var h1: UIColor { get set }

    /// H2 foreground UIColor
    var h2: UIColor { get set }

    /// H3 foreground UIColor
    var h3: UIColor { get set }

    /// H4 foreground UIColor
    var h4: UIColor { get set }

    /// H5 foreground UIColor
    var h5: UIColor { get set }

    /// H6 foreground UIColor
    var h6: UIColor { get set }

    /// Inline code foreground UIColor
    var inlineCodeForeground: UIColor { get set }

    /// Inline code background UIColor
    var inlineCodeBackground: UIColor { get set }

    /// Link foreground UIColor
    var link: UIColor { get set }

    /// Link underline UIColor
    var linkUnderline: UIColor { get set }

    /// Paragraph foreground UIColor
    var paragraph: UIColor { get set }
    
    var quoteBackground: UIColor { get set }
    
    var quoteForeground: UIColor { get set }
}

// Paragraph Style
public protocol ParagraphStyle {
    var lineSpacing: CGFloat { get set }
    var paragraphSpacing: CGFloat { get set }
    var alignment: NSTextAlignment { get set }
    var minimumLineHeight: CGFloat { get set }
}

// CodeBlock Style
public protocol CodeBlockStyle {
    var customRender: Bool { get set }
    var font: UIFont { get set }
    var foregroundColor: UIColor { get set }
    var backgroundColor: UIColor { get set }
    var cornerRadius: CGFloat { get set }
    var padding: UIEdgeInsets { get set }
    var useHighlight: Bool { get set }
}

// List Style
public protocol ListStyle {
    var bulletColor: UIColor { get set }
    var indentation: CGFloat { get set }
    var bulletFont: UIFont { get set }
}

// Blockquote Style
public protocol BlockquoteStyle {
    var backgroundColor: UIColor { get set }
    var borderColor: UIColor { get set }
    var borderWidth: CGFloat { get set }
    var font: UIFont { get set }
    var textColor: UIColor { get set }
    var padding: UIEdgeInsets { get set }
}

public protocol ImageStyle {
    var backgroundColor: UIColor { get set }
    var borderColor: UIColor { get set }
    var borderWidth: CGFloat { get set }
    var cornerRadius: CGFloat { get set }
    var padding: UIEdgeInsets { get set }
    var size: CGSize { get set }
    var contentMode: UIView.ContentMode { get set }
}

// Table Style
public protocol TableStyle {
    var borderColor: UIColor { get set }
    var borderWidth: CGFloat { get set }
    var padding: UIEdgeInsets { get set }
    var headerBackgroundColor: UIColor { get set }
    var headerTextColor: UIColor { get set }
    var rowAlternateBackgroundColor: UIColor? { get set }
    var cellWidth: CGFloat { get set }
    var cellHeight: CGFloat { get set }
    var cellPadding: UIEdgeInsets { get set }
    var cellMaximumWidth: CGFloat { get set }
    var maximumNumberOfLines: Int { get set }
}

// Style
public protocol Style {
    var useMPTextKit: Bool { get set }
    var hasStrikethrough: Bool { get set }
    var softbreakSeparator: String { get set }
    var maxContainerWidth: CGFloat { get set }

    var fonts: FontStyle { get set }
    var colors: ColorStyle { get set }
    var paragraphStyle: ParagraphStyle { get set }
    var codeBlockStyle: CodeBlockStyle { get set }
    var listStyle: ListStyle { get set }

    var linkUnderlineStyle: NSUnderlineStyle { get set }
    var blockquoteStyle: BlockquoteStyle { get set }
    var tableStyle: TableStyle { get set }
    var imageStyle: ImageStyle { get set }
    var needTruncation: Bool { get set }
    var maximumNumberOfLines: NSInteger { get set }
}

// 实现各个默认样式的结构体
struct DefaultFontStyle: FontStyle {
    var current: UIFont = .systemFont(ofSize: 18, weight: .regular)
    var h1: UIFont = .systemFont(ofSize: 22, weight: .bold)
    var h2: UIFont = .systemFont(ofSize: 19, weight: .bold)
    var h3: UIFont = .systemFont(ofSize: 19, weight: .bold)
    var h4: UIFont = .systemFont(ofSize: 19, weight: .bold)
    var h5: UIFont = .systemFont(ofSize: 19, weight: .bold)
    var h6: UIFont = .systemFont(ofSize: 19, weight: .bold)
    var paragraph: UIFont = .systemFont(ofSize: 18, weight: .regular)
    var inlineCodeFont: UIFont = .systemFont(ofSize: 18, weight: .regular)
    var quoteFont: UIFont = .systemFont(ofSize: 12, weight: .light)
}

struct DefaultColorStyle: ColorStyle {
    var current: UIColor = .black
    var h1: UIColor = .black
    var h2: UIColor = .black
    var h3: UIColor = .black
    var h4: UIColor = .black
    var h5: UIColor = .black
    var h6: UIColor = .black
    var inlineCodeForeground: UIColor = .black
    var inlineCodeBackground: UIColor = .gray.withAlphaComponent(0.3)
    var quoteBackground: UIColor = .gray.withAlphaComponent(0.3)
    var quoteForeground: UIColor = .black
    var link: UIColor = .init(red: 0, green: 0.439, blue: 0.788, alpha: 1)
    var linkUnderline: UIColor = .systemBlue
    var paragraph: UIColor = .black
}

struct DefaultParagraphStyle: ParagraphStyle {
    var lineSpacing: CGFloat = 0
    var paragraphSpacing: CGFloat = 0
    var alignment: NSTextAlignment = .left
    var minimumLineHeight: CGFloat = 0
}

struct DefaultCodeBlockStyle: CodeBlockStyle {
    var customRender: Bool = true
    var font: UIFont = .monospacedSystemFont(ofSize: 16, weight: .regular)
    var foregroundColor: UIColor = .black
    var backgroundColor: UIColor = .black.withAlphaComponent(0.06)
    var cornerRadius: CGFloat = 8
    var padding: UIEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
    var useHighlight: Bool = true
}

struct DefaultListStyle: ListStyle {
    var bulletColor: UIColor = .black
    var indentation: CGFloat = 20
    var bulletFont: UIFont = .systemFont(ofSize: 18)
}

struct DefaultBlockquoteStyle: BlockquoteStyle {
    var backgroundColor: UIColor = .clear
    var borderColor: UIColor = .init(red: 0.906, green: 0.906, blue: 0.906, alpha: 1)
    var borderWidth: CGFloat = 2
    var font: UIFont = .italicSystemFont(ofSize: 18)
    var textColor: UIColor = .black
    var padding: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
}

public struct DefaultTableStyle: TableStyle {
    public var borderColor: UIColor = .lightGray
    public var borderWidth: CGFloat = 1
    public var padding: UIEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
    public var cellWidth: CGFloat = 60
    public var cellHeight: CGFloat = 44
    public var headerBackgroundColor: UIColor = .lightGray
    public var headerTextColor: UIColor = .black
    public var rowAlternateBackgroundColor: UIColor? = .systemGray6
    public var cellPadding: UIEdgeInsets = .init(top: 6, left: 16, bottom: 6, right: 16)
    public var cellMaximumWidth: CGFloat = UIScreen.main.bounds.width - 12 - 32
    public var maximumNumberOfLines: Int = 2

    public init() {}
}

struct DefaultImageStyle: ImageStyle {
    var backgroundColor: UIColor = .lightGray
    var borderColor: UIColor = .clear
    var borderWidth: CGFloat = 0
    var cornerRadius: CGFloat = 4
    var padding: UIEdgeInsets = .zero
    var size: CGSize = CGSizeMake(UIScreen.main.bounds.width - 12 - 16, UIScreen.main.bounds.width - 12 - 16)
    var contentMode: UIView.ContentMode = .scaleAspectFill
}

public extension Style {
    /// Returns the font for the specified heading.
    ///
    /// - Parameters:
    ///     - heading: The heading.
    /// - Returns:
    ///     - The font for the heading.
    func font(forHeading heading: Heading) -> UIFont {
        switch heading.level {
        case 1:
            return fonts.h1
        case 2:
            return fonts.h2
        case 3:
            return fonts.h3
        case 4:
            return fonts.h4
        case 5:
            return fonts.h5
        case 6:
            return fonts.h6
        default:
            return fonts.paragraph
        }
    }

    /// Returns the color for the specified heading.
    ///
    /// - Parameters:
    ///     - heading: The heading.
    /// - Returns:
    ///     - The color for the heading.
    func color(forHeading heading: Heading) -> UIColor {
        switch heading.level {
        case 1:
            return colors.h1
        case 2:
            return colors.h2
        case 3:
            return colors.h3
        case 4:
            return colors.h4
        case 5:
            return colors.h5
        case 6:
            return colors.h6
        default:
            return colors.paragraph
        }
    }
}

public struct MarkdownStyle: Style {
    public var useMPTextKit: Bool
    public var fonts: FontStyle
    public var colors: ColorStyle
    public var paragraphStyle: ParagraphStyle
    public var codeBlockStyle: CodeBlockStyle
    public var listStyle: ListStyle
    public var hasStrikethrough: Bool
    public var softbreakSeparator: String
    public var linkUnderlineStyle: NSUnderlineStyle
    public var blockquoteStyle: BlockquoteStyle
    public var tableStyle: TableStyle
    public var maxContainerWidth: CGFloat
    public var imageStyle: ImageStyle
    public var needTruncation: Bool = false
    public var maximumNumberOfLines: NSInteger = 7

    public init(
        useMPTextKit: Bool,
        fonts: FontStyle,
        colors: ColorStyle,
        paragraphStyle: ParagraphStyle,
        codeBlockStyle: CodeBlockStyle,
        listStyle: ListStyle,
        hasStrikethrough: Bool,
        softbreakSeparator: String,
        linkUnderlineStyle: NSUnderlineStyle,
        blockquoteStyle: BlockquoteStyle,
        tableStyle: TableStyle,
        maxContainerWidth: CGFloat,
        imageStyle: ImageStyle
    ) {
        self.useMPTextKit = useMPTextKit
        self.fonts = fonts
        self.colors = colors
        self.paragraphStyle = paragraphStyle
        self.codeBlockStyle = codeBlockStyle
        self.listStyle = listStyle
        self.hasStrikethrough = hasStrikethrough
        self.softbreakSeparator = softbreakSeparator
        self.linkUnderlineStyle = linkUnderlineStyle
        self.blockquoteStyle = blockquoteStyle
        self.tableStyle = tableStyle
        self.maxContainerWidth = maxContainerWidth
        self.imageStyle = imageStyle
    }

    public static func defaultStyle() -> MarkdownStyle {
        return MarkdownStyle(
            useMPTextKit: true,
            fonts: DefaultFontStyle(),
            colors: DefaultColorStyle(),
            paragraphStyle: DefaultParagraphStyle(),
            codeBlockStyle: DefaultCodeBlockStyle(),
            listStyle: DefaultListStyle(),
            hasStrikethrough: false,
            softbreakSeparator: "\n",
            linkUnderlineStyle: .single,
            blockquoteStyle: DefaultBlockquoteStyle(),
            tableStyle: DefaultTableStyle(),
            maxContainerWidth: UIScreen.main.bounds.width - 40,
            imageStyle: DefaultImageStyle()
        )
    }
}

public typealias FontDescriptorSymbolicTraits = UIFontDescriptor.SymbolicTraits

/// Font extensions.
public extension UIFont {
    func gmark_with(trait: FontDescriptorSymbolicTraits) -> UIFont {
        var font = self
        var traits = fontDescriptor.symbolicTraits
        traits.insert(trait)
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            font = UIFont(descriptor: descriptor, size: 0.0)
        }

        return font
    }

    /// Returns the font with the bold trait set.
    ///
    /// - Returns:
    ///     The font with the bold trait set.
    func gmark_bold() -> UIFont {
        return gmark_with(trait: .traitBold)
    }

    /// Returns the font with the italic trait set.
    ///
    /// - Returns:
    ///     The font with the italic trait set.
    func gmark_italic() -> UIFont {
        return gmark_with(trait: .traitItalic)
    }
}

// MARK: - Helper

extension UIColor {
    /// 初始化 UIColor 使用十六进制字符串
    /// - Parameters:
    ///   - hex: 十六进制字符串，可以以 "#" 开头或不以 "#" 开头
    ///   - alpha: 颜色的透明度，值范围从 0.0 到 1.0
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
