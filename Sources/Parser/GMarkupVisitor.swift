//
//  GMarkupVisitor.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/25.
//

import Markdown
import UIKit
#if canImport(MPITextKit)
import MPITextKit
#endif
import SwiftMath

public struct GMarkupVisitor: MarkupVisitor {
    
    // MARK: - Properties
    
    public var ignoreLatex: Bool = false
    public var beginLatex: Bool = false
    public var beginSupTag: Bool = false
    
    private let style: Style
    public var referLoader: ReferLoader?
    public var imageLoader: ImageLoader?
    
    public init(style: Style) {
        self.style = style
    }
    
    public typealias Result = NSAttributedString
    
    // MARK: - Visit Methods
    
    public mutating func defaultVisit(_ markup: Markup) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for child in markup.children {
            result.append(visit(child))
        }
        return result
    }
    
    public mutating func visitText(_ text: Text) -> NSAttributedString {
        if beginLatex {
            return handleLatexText(text)
        }
        
        if beginSupTag {
            return handleSupTag(from: text)
        }
        
        return defaultAttribute(from: text.plainText)
    }
    
    public mutating func visitImage(_ image: Image) -> NSAttributedString {
        guard style.useMPTextKit, let source = image.source else {
            return NSMutableAttributedString(string: "")
        }
        return handleImage(source: source)
    }
    
    public mutating func visitEmphasis(_ emphasis: Emphasis) -> NSAttributedString {
        let attributedString = processChildren(of: emphasis)
        applyItalicFont(to: attributedString)
        return attributedString
    }
    
    public mutating func visitStrong(_ strong: Strong) -> NSAttributedString {
        let attributedString = processChildren(of: strong)
        applyBoldFont(to: attributedString)
        return attributedString
    }
    
    public mutating func visitParagraph(_ paragraph: Paragraph) -> NSAttributedString {
        let attributedString = processChildren(of: paragraph)
        appendNewlineIfNeeded(for: paragraph, to: attributedString)
        return attributedString
    }
    
    public mutating func visitHeading(_ heading: Heading) -> NSAttributedString {
        let attributedString = processChildren(of: heading)
        applyHeadingStyle(to: attributedString, heading: heading)
        appendNewlineIfNeeded(for: heading, to: attributedString)
        return attributedString
    }
    
    public mutating func visitLink(_ link: Link) -> NSAttributedString {
        let attributedString = processChildren(of: link)
        applyLinkStyle(to: attributedString, destination: link.destination)
        return attributedString
    }
    
    public mutating func visitInlineCode(_ inlineCode: InlineCode) -> NSAttributedString {
        let attributedString = defaultAttribute(from: inlineCode.code)
        applyInlineCodeStyle(to: attributedString)
        return attributedString
    }
    
    public mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> NSAttributedString {
        return handleCodeBlock(codeBlock)
    }
    
    public mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> NSAttributedString {
        let attributedString = processChildren(of: strikethrough)
        attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue)
        return attributedString
    }
    
    public mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> NSAttributedString {
        return handleUnorderedList(unorderedList)
    }
    
    public mutating func visitOrderedList(_ orderedList: OrderedList) -> NSAttributedString {
        return handleOrderedList(orderedList)
    }
    
    public mutating func visitListItem(_ listItem: ListItem) -> NSAttributedString {
        let attributedString = processChildren(of: listItem)
        appendNewlineIfNeeded(for: listItem, to: attributedString)
        return attributedString
    }
    
    public mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> NSAttributedString {
        return handleBlockQuote(blockQuote)
    }
    
    public mutating func visitInlineHTML(_ inlineHTML: InlineHTML) -> Result {
        return handleInlineHTML(inlineHTML)
    }
    
    public mutating func visitHTMLBlock(_ html: HTMLBlock) -> Result {
        return handleHTMLBlock(html)
    }
    
    public mutating func visitLineBreak(_ lineBreak: LineBreak) -> NSAttributedString {
        return defaultAttribute(from: lineBreak.plainText)
    }
    
    public mutating func visitSoftBreak(_: SoftBreak) -> NSAttributedString {
        return NSAttributedString.singleNewline(withStyle: style)
    }
    
    // MARK: - Helper Methods
    
    private mutating func processChildren(of markup: Markup) -> NSMutableAttributedString {
        let result = NSMutableAttributedString()
        for child in markup.children {
            result.append(visit(child))
        }
        return result
    }
    
    private mutating func applyItalicFont(to attributedString: NSMutableAttributedString) {
        attributedString.enumerateAttribute(.font, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, _ in
            guard let font = value as? UIFont else { return }
            if let italicFont = font.italic {
                attributedString.addAttribute(.font, value: italicFont, range: range)
            }
        }
    }
    
    private mutating func applyBoldFont(to attributedString: NSMutableAttributedString) {
        attributedString.enumerateAttribute(.font, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, _ in
            guard let font = value as? UIFont else { return }
            if let boldFont = font.bold {
                attributedString.addAttribute(.font, value: boldFont, range: range)
            }
        }
    }
    
    private mutating func applyLinkStyle(to attributedString: NSMutableAttributedString, destination: String?) {
        guard let destination = destination, let url = URL(string: destination) else { return }
        attributedString.addAttribute(.foregroundColor, value: style.colors.link)
        if style.useMPTextKit {
            let mpiLink = MPITextLink()
            mpiLink.value = url as any NSObjectProtocol
            attributedString.addAttribute(.MPILink, value: mpiLink)
        } else {
            attributedString.addAttribute(.link, value: url)
        }
    }
    
    private mutating func applyHeadingStyle(to attributedString: NSMutableAttributedString, heading: Heading) {
        let font = style.font(forHeading: heading)
        let color = style.color(forHeading: heading)
        attributedString.addAttribute(.foregroundColor, value: color)
        attributedString.addAttribute(.font, value: font)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 25 - font.pointSize
        paragraphStyle.paragraphSpacing = 16
        // 设置文本方向和对齐方式
        let isRTL = isRTLLanguage(text: attributedString.string)
        paragraphStyle.baseWritingDirection = isRTL ? .rightToLeft : .leftToRight
        paragraphStyle.alignment = isRTL ? .right : .left
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle)
    }
    
    private mutating func applyInlineCodeStyle(to attributedString: NSMutableAttributedString) {
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
    
    private mutating func appendNewlineIfNeeded(for markup: Markup, to attributedString: NSMutableAttributedString) {
        if markup.hasSuccessor {
            let newline = markup.isContainedInList ? NSAttributedString.singleNewline(withStyle: style) : NSAttributedString.singleNewline(withStyle: style)
            attributedString.append(newline)
        }
    }
    
    private mutating func handleLatexText(_ text: Text) -> NSAttributedString {
        guard text.plainText != "[" && text.plainText != "]" else {
            return defaultAttribute(from: "")
        }
        let trimmedText = trimBrackets(from: text.plainText)
        var mathImage = MathImage(latex: trimmedText, fontSize: style.fonts.current.pointSize, textColor: style.colors.current)
        mathImage.font = MathFont.xitsFont
        
        let (_, image) = mathImage.asImage()
        
        if let image = image {
            let resizedImage = image.resized(toMaxWidth: style.maxContainerWidth - 40)
            let result = NSMutableAttributedString(string: "")
            
            if style.useMPTextKit {
                // 使用 MPITextAttachment
                let attachment = MPITextAttachment()
                attachment.content = resizedImage
                attachment.contentSize = resizedImage.size
                attachment.contentMode = .left
                attachment.verticalAligment = .center
                let attrString = NSMutableAttributedString(attachment: attachment)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 25 - style.fonts.current.pointSize
                paragraphStyle.paragraphSpacing = 16
                attrString.addAttribute(.paragraphStyle, value: paragraphStyle)
                attrString.addAttribute(.font, value: style.fonts.current)
                attrString.addAttribute(.foregroundColor, value: style.colors.current)
                
                result.append(attrString)
            } else {
                // 使用 NSTextAttachment
                let attachment = NSTextAttachment()
                attachment.image = resizedImage
                attachment.bounds = CGRect(x: 0, y: 0, width: resizedImage.size.width, height: resizedImage.size.height)
                
                let attrString = NSMutableAttributedString(attachment: attachment)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 25 - style.fonts.current.pointSize
                paragraphStyle.paragraphSpacing = 16
                attrString.addAttribute(.paragraphStyle, value: paragraphStyle)
                attrString.addAttribute(.font, value: style.fonts.current)
                attrString.addAttribute(.foregroundColor, value: style.colors.current)
                
                result.append(attrString)
            }
            
            return result
        }
        return defaultAttribute(from: text.plainText)
    }
    
    private mutating func renderLatexSynchronously(image: UIImage) -> NSAttributedString {
        let result = NSMutableAttributedString()
        if image.size.width > style.maxContainerWidth {
            let sv = UIScrollView()
            sv.contentSize = image.size
            let iv = UIImageView(image: image)
            iv.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            sv.addSubview(iv)
            
            let attachment = MPITextAttachment()
            attachment.content = sv
            attachment.contentSize = CGSize(width: style.maxContainerWidth, height: image.size.height)
            attachment.verticalAligment = .center
            let attrString = NSMutableAttributedString(attachment: attachment)
            applyDefaultParagraphStyle(to: attrString)
            result.append(attrString)
        } else {
            let attachment = MPITextAttachment()
            attachment.image = image
            attachment.contentSize = image.size
            attachment.contentMode = .left
            attachment.verticalAligment = .center
            let attrString = NSMutableAttributedString(attachment: attachment)
            applyDefaultParagraphStyle(to: attrString)
            result.append(attrString)
        }
        return result
    }
    
    private mutating func renderLatexAsynchronously(image: UIImage) -> NSAttributedString {
        let semaphore = DispatchSemaphore(value: 0)
        let result = NSMutableAttributedString()
        loadLatexAsync(from: image, style: style) { attrString in
            result.append(attrString)
            semaphore.signal()
        }
        semaphore.wait()
        return result
    }
    
    private mutating func handleSupTag(from text: Text) -> NSAttributedString {
        guard let referLoader = referLoader,
              let link = referLoader.referQuoteLink(from: text.plainText),
              let webSite = referLoader.referQuoteWebSite(from: text.plainText),
              !webSite.isEmpty else {
            return defaultAttribute(from: "")
        }
        
        let tagImage = Renderer().drawTagImage(
            text: webSite,
            font: style.fonts.quoteFont,
            width: calculateTagWidth(for: webSite),
            height: 28,
            backgroundColor: style.colors.quoteBackground,
            textColor: style.colors.quoteForeground,
            cornerRadius: 14
        )
        
        guard let image = tagImage else {
            return defaultAttribute(from: "")
        }
        
        let attachment = MPITextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: -7, width: image.size.width, height: image.size.height)
        let attrString = NSMutableAttributedString(attachment: attachment)
        attrString.insert(NSAttributedString(string: " "), at: 0)
        
        if let url = URL(string: link) {
            let mpiLink = MPITextLink()
            mpiLink.value = url as any NSObjectProtocol
            attrString.addAttribute(.MPILink, value: mpiLink)
        }
        
        return attrString
    }
    
    private func calculateTagWidth(for text: String) -> CGFloat {
        let textWidth = (text as NSString).size(withAttributes: [.font: style.fonts.quoteFont]).width
        let padding: CGFloat = 12
        return min(textWidth + 18 + padding * 2, 180)
    }
    
    private mutating func handleBlockQuote(_ blockQuote: BlockQuote) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        // 设置基准缩进为 10.0，深度偏移也为 10.0，最大深度为 5
        let config = BlockQuoteConfig(baseLeftMargin: 15.0, depthOffset: 20.0, maxDepth: 5)
        
        for child in blockQuote.children {
            let attributes = createQuoteAttributes(depth: blockQuote.quoteDepth, config: config)
            if let childAttributed = processChildInBlockQuote(child, attributes: attributes) {
                attributedString.append(childAttributed)
            }
        }
        
        if blockQuote.hasSuccessor {
            attributedString.append(blockQuote.isContainedInList ? .singleNewline(withStyle: style) : .doubleNewline(withStyle: style))
        }
        
        return attributedString
    }
    
    private func createQuoteAttributes(depth: Int, config: BlockQuoteConfig) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        let paragraphStyle = NSMutableParagraphStyle()
        
        // 计算有效深度，防止超过最大深度
        let effectiveDepth = min(depth, config.maxDepth)
        // 每一级深度增加 10.0 的缩进
        let leftIndent = config.baseLeftMargin + (config.depthOffset * CGFloat(effectiveDepth))
        
        // 统一首行和其他行的缩进为 leftIndent
        paragraphStyle.firstLineHeadIndent = leftIndent
        paragraphStyle.headIndent = leftIndent
        
        // 设置行间距，可以根据需要调整
        paragraphStyle.lineSpacing = max(5, 25 - style.fonts.current.pointSize)
        paragraphStyle.paragraphSpacing = 16
        attributes[.paragraphStyle] = paragraphStyle
        attributes[.font] = style.blockquoteStyle.font
        attributes[.foregroundColor] = style.blockquoteStyle.textColor
        attributes[.quoteDepth] = depth
        
        return attributes
    }
    
    private mutating func processChildInBlockQuote(_ child: Markup, attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString? {
        guard let childAttributed = visit(child) as? NSMutableAttributedString else { return nil }
        
        // 应用引用块的段落样式和其它属性
        let range = NSRange(location: 0, length: childAttributed.length)
        childAttributed.addAttributes(attributes, range: range)
        
        applyQuoteStyle(to: childAttributed)
        return childAttributed
    }
    
    private mutating func applyQuoteStyle(to attributedString: NSMutableAttributedString) {
        // 这里已经在 createQuoteAttributes 中设置了 foregroundColor，所以可以选择去除这部分
        // 如果需要额外的样式，可以保留或调整
        /*
         attributedString.addAttribute(.foregroundColor, value: style.blockquoteStyle.textColor)
         */
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
    
    
    
    private mutating func handleInlineHTML(_ inlineHTML: InlineHTML) -> Result {
        
        if !ignoreLatex {
            switch inlineHTML.plainText {
            case "<LaTex>":
                beginLatex = true
            case "</LaTex>":
                beginLatex = false
            default:
                break
            }
        }
        switch inlineHTML.plainText {
        case "<br>":
            return .singleNewline(withStyle: style)
        case "<sup>":
            beginSupTag = true
            return defaultVisit(inlineHTML)
        case "</sup>":
            beginSupTag = false
            return defaultVisit(inlineHTML)
        default:
            return defaultVisit(inlineHTML)
        }
    }
    
    private mutating func handleHTMLBlock(_ html: HTMLBlock) -> Result {
        
        return defaultAttribute(from: html.rawHTML)
        
    }
    
    private mutating func handleCodeBlock(_ codeBlock: CodeBlock) -> NSAttributedString {
        let code = codeBlock.code.trimmingCharacters(in: .whitespacesAndNewlines)
        if style.codeBlockStyle.customRender {
            return renderCustomCodeBlock(code, language: codeBlock.language)
        }
        if style.codeBlockStyle.useHighlight {
            return renderHighlightedCodeBlock(code, language: codeBlock.language, hasSuccessor: codeBlock.hasSuccessor)
        }
        
        return renderDefaultCodeBlock(code, hasSuccessor: codeBlock.hasSuccessor)
    }
    
    private mutating func renderCustomCodeBlock(_ code: String, language: String?) -> NSAttributedString {
        if style.codeBlockStyle.useHighlight {
            if let highlighted = GMarkCodeHighlight.shared.generateAttributeText(code, language: language ?? ""),
               !highlighted.string.hasPrefix("undefined") {
                let attributed = NSMutableAttributedString(attributedString: highlighted)
                attributed.addAttribute(.font, value: style.codeBlockStyle.font)
                return attributed
            }
        }
        
        let attributed = defaultAttribute(from: code)
        attributed.addAttribute(.font, value: style.codeBlockStyle.font)
        attributed.addAttribute(.foregroundColor, value: style.codeBlockStyle.foregroundColor)
        return attributed
    }
    
    private mutating func renderHighlightedCodeBlock(_ code: String, language: String?, hasSuccessor: Bool) -> NSAttributedString {
        guard let highlighted = GMarkCodeHighlight.shared.generateAttributeText(code, language: language ?? ""),
              !highlighted.string.hasPrefix("undefined") else {
            return renderDefaultCodeBlock(code, hasSuccessor: hasSuccessor)
        }
        
        let attributed = NSMutableAttributedString(string: "")
        attributed.append(.singleNewline(withStyle: style))
        attributed.append(highlighted)
        attributed.addAttribute(.font, value: style.codeBlockStyle.font)
        if style.useMPTextKit {
            let background = MPITextBackground(fill: style.codeBlockStyle.backgroundColor, cornerRadius: 4)
            attributed.addAttribute(.MPIBlockBackground, value: background)
        } else {
            attributed.addAttribute(.backgroundColor, value: style.codeBlockStyle.backgroundColor)
        }
    
        if hasSuccessor {
            attributed.append(.singleNewline(withStyle: style))
        }
        attributed.append(.singleNewline(withStyle: style))
        return attributed
    }
    
    private mutating func renderDefaultCodeBlock(_ code: String, hasSuccessor: Bool) -> NSAttributedString {
        let attributed = defaultAttribute(from: "\n\(code)")
        attributed.addAttribute(.font, value: style.codeBlockStyle.font)
        attributed.addAttribute(.foregroundColor, value: style.codeBlockStyle.foregroundColor)
        
        if style.useMPTextKit {
            let background = MPITextBackground(fill: style.codeBlockStyle.backgroundColor, cornerRadius: 4)
            attributed.addAttribute(.MPIBlockBackground, value: background)
        } else {
            attributed.addAttribute(.backgroundColor, value: style.codeBlockStyle.backgroundColor)
        }
        
        if hasSuccessor {
            attributed.append(.singleNewline(withStyle: style))
        }
        return attributed
    }
    
    public mutating func handleOrderedList(_ orderedList: OrderedList) -> NSAttributedString {
        let result = defaultAttribute(from: "")
        
        for (index, listItem) in orderedList.listItems.enumerated() {
            var listItemAttributes: [NSAttributedString.Key: Any] = [:]
            
            let listItemAttributedString = visit(listItem).mutableCopy() as! NSMutableAttributedString
            let isRTL = isRTLLanguage(text: listItemAttributedString.string)
            
            let font = style.fonts.current
            let numeralFont = style.listStyle.bulletFont
            
            let listItemParagraphStyle = NSMutableParagraphStyle()
            listItemParagraphStyle.lineSpacing = 25 - font.pointSize
            listItemParagraphStyle.paragraphSpacing = 14
            listItemParagraphStyle.baseWritingDirection = isRTL ? .rightToLeft : .leftToRight
            listItemParagraphStyle.alignment = isRTL ? .right : .left
            // Implement a base amount to be spaced from the left side at all times to better visually differentiate it as a list
            let baseLeftMargin: CGFloat = 5.0
            let leftMarginOffset = baseLeftMargin + (20.0 * CGFloat(orderedList.listDepth))
            
            // Grab the highest number to be displayed and measure its width (yes normally some digits are wider than others but since we're using the numeral mono font all will be the same width in this case)
            let highestNumberInList = orderedList.childCount
            let numeralColumnWidth = ceil(NSAttributedString(string: "\(highestNumberInList).", attributes: [.font: numeralFont]).size().width)
            
            let spacingFromIndex: CGFloat = 8.0
            let firstTabLocation = leftMarginOffset + numeralColumnWidth
            let secondTabLocation = firstTabLocation + spacingFromIndex
            
            listItemParagraphStyle.tabStops = [
                NSTextTab(textAlignment: .right, location: firstTabLocation),
                NSTextTab(textAlignment: .left, location: secondTabLocation),
            ]
            
            listItemParagraphStyle.headIndent = secondTabLocation
            
            listItemAttributes[.paragraphStyle] = listItemParagraphStyle
            listItemAttributes[.font] = font
            listItemAttributes[.foregroundColor] = style.colors.current
            listItemAttributes[.listDepth] = orderedList.listDepth
            
            
            
            // Same as the normal list attributes, but for prettiness in formatting we want to use the cool monospaced numeral font
            var numberAttributes = listItemAttributes
            numberAttributes[.font] = numeralFont
            numberAttributes[.foregroundColor] = style.colors.current
            
            let taps = isRTL ? " " : "\t"
            
            if Int(orderedList.startIndex) > 0 {
                let numberAttributedString = NSAttributedString(string: "\t\(Int(orderedList.startIndex) + index).\(taps)", attributes: numberAttributes)
                listItemAttributedString.insert(numberAttributedString, at: 0)
            } else {
                let numberAttributedString = NSAttributedString(string: "\t\(index + 1).\(taps)", attributes: numberAttributes)
                listItemAttributedString.insert(numberAttributedString, at: 0)
            }
            result.append(listItemAttributedString)
        }
        
        if orderedList.hasSuccessor {
            result.append(orderedList.isContainedInList ? .singleNewline(withStyle: style) : .doubleNewline(withStyle: style))
        }
        
        return result
    }
    
    public mutating func handleUnorderedList(_ unorderedList: UnorderedList) -> NSAttributedString {
        let result = defaultAttribute(from: "")
        
        let font = style.fonts.current
        
        for listItem in unorderedList.listItems {
            
            let listItemAttributedString = visit(listItem).mutableCopy() as! NSMutableAttributedString
            let isRTL = isRTLLanguage(text: listItemAttributedString.string)
            
            var listItemAttributes: [NSAttributedString.Key: Any] = [:]
            let listItemParagraphStyle = NSMutableParagraphStyle()
            listItemParagraphStyle.lineSpacing = 25 - font.pointSize
            listItemParagraphStyle.paragraphSpacing = 14
            let baseLeftMargin: CGFloat = 5.0
            let leftMarginOffset = baseLeftMargin + (20.0 * CGFloat(unorderedList.listDepth))
            let spacingFromIndex: CGFloat = 8.0
            let bulletWidth = ceil(NSAttributedString(string: "•", attributes: [.font: font, .foregroundColor: style.colors.current]).size().width)
            let firstTabLocation = leftMarginOffset + bulletWidth
            let secondTabLocation = firstTabLocation + spacingFromIndex
            
            listItemParagraphStyle.tabStops = [
                NSTextTab(textAlignment: .right, location: firstTabLocation),
                NSTextTab(textAlignment: .left, location: secondTabLocation),
            ]
            listItemParagraphStyle.baseWritingDirection = isRTL ? .rightToLeft : .leftToRight
            listItemParagraphStyle.alignment = isRTL ? .right : .left
            listItemParagraphStyle.headIndent = secondTabLocation
            listItemAttributes[.paragraphStyle] = listItemParagraphStyle
            listItemAttributes[.font] = font
            listItemAttributes[.foregroundColor] = style.colors.current
            listItemAttributes[.listDepth] = unorderedList.listDepth
            
            let taps = isRTL ? " " : "\t"
            listItemAttributedString.insert(NSAttributedString(string: "\t•\(taps)", attributes: listItemAttributes), at: 0)
            
            result.append(listItemAttributedString)
        }
        
        if unorderedList.hasSuccessor {
            result.append(.doubleNewline(withStyle: style))
        }
        
        return result
    }
    
    private func handleImage(source: String) -> NSAttributedString {
        if Thread.isMainThread {
            return createImageAttributedString(source: source)
        } else {
            let semaphore = DispatchSemaphore(value: 0)
            var resultString: NSAttributedString!
            DispatchQueue.main.async {
                resultString =  self.createImageAttributedString(source: source)
                semaphore.signal()
            }
            
            semaphore.wait()
            return resultString
        }
    }

    // 原来的实例方法
    private func createImageAttributedString(source: String) -> NSAttributedString {
        return GMarkupVisitor.createImageAttributedStringStatic(source: source, style: self.style,imageLoader: imageLoader)
    }

    // 静态方法，不需要访问实例属性
    private static func createImageAttributedStringStatic(source: String, style: Style, imageLoader:ImageLoader?) -> NSAttributedString {
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
    
    private func loadLatexAsync(from image: UIImage, style: Style, completion: @escaping (NSAttributedString) -> Void) {
        DispatchQueue.main.async {
            let sv = UIScrollView()
            sv.contentSize = image.size
            let iv = UIImageView(image: image)
            iv.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            sv.addSubview(iv)
            
            let attachment = MPITextAttachment()
            attachment.content = sv
            attachment.contentSize = CGSize(width: style.maxContainerWidth, height: image.size.height)
            attachment.verticalAligment = .center
            
            let attrString = NSMutableAttributedString(attachment: attachment)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 25 - style.fonts.current.pointSize
            paragraphStyle.paragraphSpacing = 16
            attrString.addAttribute(.paragraphStyle, value: paragraphStyle)
            attrString.addAttribute(.font, value: style.fonts.current)
            attrString.addAttribute(.foregroundColor, value: style.colors.current)
            completion(attrString)
        }
    }
    
    func trimBrackets(from string: String) -> String {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedString.hasPrefix("[") && (trimmedString.hasSuffix("]")) {
            return String(trimmedString.dropFirst().dropLast())
        }
        if trimmedString.hasPrefix("(") && (trimmedString.hasSuffix(")")) {
            return String(trimmedString.dropFirst().dropLast())
        }
        return trimmedString
    }
    
    private func calculateWidth(of text: String, withFont font: UIFont) -> CGFloat {
        return (text as NSString).size(withAttributes: [.font: font]).width
    }
    
    // MARK: - Rendering Helpers
    
    private mutating func renderHTML(_ htmlData: Data, options: [NSAttributedString.DocumentReadingOptionKey: Any]) -> NSAttributedString {
        if let attributedString = try? NSMutableAttributedString(data: htmlData, options: options, documentAttributes: nil) {
            return attributedString
        }
        return defaultAttribute(from: String(data: htmlData, encoding: .utf8) ?? "")
    }
    
    private mutating func renderLatexImage(_ image: UIImage) -> NSAttributedString {
        let attachment = MPITextAttachment()
        attachment.image = image
        attachment.contentSize = image.size
        attachment.contentMode = .left
        attachment.verticalAligment = .center
        
        let attrString = NSMutableAttributedString(attachment: attachment)
        applyDefaultParagraphStyle(to: attrString)
        return attrString
    }
    
    private mutating func renderLatexScrollView(_ image: UIImage) -> NSAttributedString {
        let sv = UIScrollView()
        sv.contentSize = image.size
        let iv = UIImageView(image: image)
        iv.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        sv.addSubview(iv)
        
        let attachment = MPITextAttachment()
        attachment.content = sv
        attachment.contentSize = CGSize(width: style.maxContainerWidth, height: image.size.height)
        attachment.verticalAligment = .center
        
        let attrString = NSMutableAttributedString(attachment: attachment)
        applyDefaultParagraphStyle(to: attrString)
        return attrString
    }
    
    private mutating func applyDefaultParagraphStyle(to attributedString: NSMutableAttributedString) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 25 - style.fonts.current.pointSize
        paragraphStyle.paragraphSpacing = 16
        let isRTL = isRTLLanguage(text: attributedString.string)
        paragraphStyle.baseWritingDirection = isRTL ? .rightToLeft : .leftToRight
        paragraphStyle.alignment = isRTL ? .right : .left
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle)
        attributedString.addAttribute(.font, value: style.fonts.current)
        attributedString.addAttribute(.foregroundColor, value: style.colors.current)
        
    }
    
    // MARK: - Block Quote Configuration
    
    private struct BlockQuoteConfig {
        let baseLeftMargin: CGFloat
        let depthOffset: CGFloat
        let maxDepth: Int
    }
}


// MARK: - Public Attribute Implementation
extension GMarkupVisitor {
    public func buildAttributedText(from text: String) -> NSMutableAttributedString {
        defaultAttribute(from: text)
    }
}

// MARK: - Default Attribute Implementation
extension GMarkupVisitor {
    
    func defaultAttribute(from text: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        
        var attributes: [NSAttributedString.Key: Any] = [:]
        
        attributes[.font] = style.fonts.current
        attributes[.foregroundColor] = style.colors.current
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 25 - style.fonts.current.pointSize
        paragraphStyle.paragraphSpacing = 16 // 段落间距为16
        // 设置文本方向和对齐方式
        let isRTL = isRTLLanguage(text: text)
        paragraphStyle.baseWritingDirection = isRTL ? .rightToLeft : .leftToRight
        paragraphStyle.alignment = isRTL ? .right : .left
        attributes[.paragraphStyle] = paragraphStyle
        
        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: text.utf16.count))
        
        return attributedString
    }
}

extension GMarkupVisitor {
    /// 检测文本是否为RTL语言
    /// - Parameter text: 要检测的文本
    /// - Returns: 如果是RTL语言返回`true`，否则返回`false`
    private func isRTLLanguage(text: String) -> Bool {
        // 定义一个辅助函数，用于判断字符是否为数字或符号
        func isNumberOrSymbol(_ character: Character) -> Bool {
            // 使用Character的属性来判断
            return character.isNumber || character.isPunctuation || character.isSymbol || character.isWhitespace
        }
        
        // 遍历文本中的字符，跳过所有前导的数字和符号
        for character in text {
            
            if isNumberOrSymbol(character) {
                continue // 跳过数字和符号
            }
            // 找到第一个非数字且非符号的字符，进行RTL判断
            if let firstScalar = character.unicodeScalars.first {
                let codePoint = firstScalar.value
                // 阿拉伯语和希伯来语的Unicode范围
                switch codePoint {
                case 0x0590...0x08FF,   // 包含希伯来语、阿拉伯语等
                    0xFB1D...0xFDFF,
                    0xFE70...0xFEFF,
                    0x1EE00...0x1EEFF:
                    return true
                default:
                    return false
                }
            }
        }
        
        // 如果文本为空或未检测到RTL字符，可以根据系统语言或其他逻辑决定
        // 这里以系统当前语言为准
        let language = Locale.current.languageCode ?? "en"
        let rtlLanguages = ["ar", "he", "fa", "ur"] // 常见的RTL语言
        return rtlLanguages.contains(language)
    }
}



// MARK: - Renderer Helper

private struct Renderer {
    
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

extension UIImage {
    /// 根据给定的最大宽度调整图片大小，同时保持比例不变。
    /// - Parameter maxWidth: 图片的最大宽度。
    /// - Returns: 调整后的UIImage实例。如果原始宽度小于或等于maxWidth，则返回原图。
    func resized(toMaxWidth maxWidth: CGFloat) -> UIImage {
        // 检查是否需要调整大小
        if self.size.width <= maxWidth {
            return self
        }
        
        // 计算缩放比例以保持纵横比
        let scaleFactor = maxWidth / self.size.width
        let newHeight = self.size.height * scaleFactor
        let newSize = CGSize(width: maxWidth, height: newHeight)
        
        // 开始图形上下文并绘制调整后的图片
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let resizedImage {
            return resizedImage
        }
        return self
    }
}

