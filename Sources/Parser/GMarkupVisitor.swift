//
//  GMarkupVisitor.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/25.
//

import UIKit
import Markdown
#if canImport(MPITextKit)
import MPITextKit
#endif
import SwiftMath

public struct GMarkupVisitor: MarkupVisitor {
  
  public var imageLoader: ImageLoader?
  
  public var beginLatex: Bool = false
  
  private let style: Style
  
  init(style: Style) {
    self.style = style
  }
  
  public typealias Result = NSAttributedString
  
  public mutating func defaultVisit(_ markup: Markup) -> NSAttributedString {
    let result = NSMutableAttributedString()
    for child in markup.children {
      result.append(visit(child))
    }
    return result
  }
  
  public mutating func visitText(_ text: Text) -> NSAttributedString {
    if beginLatex {
//      print("Latex Text: \(text.plainText)")
      var mImage = MathImage(latex: text.plainText, fontSize: style.fonts.current.pointSize, textColor: style.colors.current)
      mImage.font = MathFont.termesFont
      let (_, image) = mImage.asImage()
      if let image = image {
        let result = NSMutableAttributedString(string: "")
        
        let attachment = MPITextAttachment()
        attachment.content = image
        attachment.contentSize =  image.size
        attachment.verticalAligment = .center
        let attrString = NSMutableAttributedString(attachment: attachment)
        result.append(attrString)
        return result
      }
    }
    return defaultAttribute(from: text.plainText)
  }
  
  public mutating func visitImage(_ image: Image) -> NSAttributedString {
      var result = NSMutableAttributedString(string: "")
      
      if style.useMPTextKit {
          guard let source = image.source else { return result }
          
          let semaphore = DispatchSemaphore(value: 0)
          
          loadImageAsync(from: source, style: style) { attrString in
              result.append(attrString)
              semaphore.signal()
          }
          
          semaphore.wait()
      }
      
      return result
  }

  private func loadImageAsync(from source: String, style: Style, completion: @escaping (NSAttributedString) -> Void) {
    DispatchQueue.main.async {
      let imageView = UIImageView()
      imageView.backgroundColor = style.imageStyle.backgroundColor
      imageView.layer.cornerRadius = style.imageStyle.cornerRadius
      imageView.layer.masksToBounds = true
      imageView.contentMode = style.imageStyle.contentMode
      imageView.clipsToBounds = true
      
      if let loader = GMarkPluginManager.shared.imageLoader {
        loader.loadImage(from: source, into: imageView)
      }
      
      let attachment = MPITextAttachment()
      attachment.content = imageView
      attachment.contentSize = style.imageStyle.size
      attachment.contentInsets = style.imageStyle.padding
      attachment.verticalAligment = .center
      
      let attrString = NSMutableAttributedString(attachment: attachment)
      if let imageURL = URL(string: source) {
        attrString.addAttribute(.link, value: imageURL)
      }
      let link = MPITextLink()
      link.value = NSURL(string: source)
      attrString.addAttribute(.MPILink, value: link)
      
      completion(attrString)
    }
  }
  
  public mutating func visitEmphasis(_ emphasis: Emphasis) -> NSAttributedString {
    
    let result = defaultAttribute(from:"")
    for child in emphasis.children {
      result.append(visit(child))
    }
    result.applyEmphasis()
    
    return result
  }
  
  public mutating func visitStrong(_ strong: Strong) -> NSAttributedString {
    
    let result = defaultAttribute(from:"")
    for child in strong.children {
      result.append(visit(child))
    }
    result.applyStrong()
    
    return result
  }
  
  public mutating func visitParagraph(_ paragraph: Paragraph) -> NSAttributedString {
    
    let result = NSMutableAttributedString()
    let color = style.colors.paragraph
    let font = style.fonts.paragraph
    result.addAttribute(.foregroundColor, value: color)
    result.addAttribute(.font, value: font)
    for child in paragraph.children {
      result.append(visit(child))
    }
    //    let paragraphStyle = NSMutableParagraphStyle()
    //    // paragraphStyle.lineSpacing = 6// style.paragraphStyle.lineSpacing
    //    //    paragraphStyle.minimumLineHeight = 26
    //    //    paragraphStyle.lineHeightMultiple = 1.4
    //    result.addAttribute(.paragraphStyle, value: paragraphStyle)
    
    if paragraph.hasSuccessor {
      result.append(paragraph.isContainedInList ? .singleNewline(withStyle: style) : .doubleNewline(withStyle: style))
    }
    return result
  }
  
  public mutating func visitHeading(_ heading: Heading) -> NSAttributedString {
    
    let result = NSMutableAttributedString()
    for child in heading.children {
      result.append(visit(child))
    }
    let font = style.font(forHeading: heading)
    let color  = style.color(forHeading: heading)
    result.addAttribute(.foregroundColor, value: color)
    result.addAttribute(.font, value: font)
    if heading.hasSuccessor {
      result.append(.doubleNewline(withStyle: style))
    }
    
    return result
  }
  
  public mutating func visitLink(_ link: Link) -> NSAttributedString {
    let result = NSMutableAttributedString()
    
    for child in link.children {
      result.append(visit(child))
    }
    
    let linkURL = link.destination != nil ? URL(string: link.destination!) : nil
    result.addAttribute(.foregroundColor, value: style.colors.link)
    if let linkURL = linkURL {
      result.addAttribute(.link, value: linkURL)
      if style.useMPTextKit {
        let mpiLink = MPITextLink()
        result.addAttribute(.MPILink, value: mpiLink)
      }
    }
    return result
  }
  
  public mutating func visitInlineCode(_ inlineCode: InlineCode) -> NSAttributedString {
    let result = defaultAttribute(from: inlineCode.code)
    result.addAttribute(.foregroundColor, value: style.colors.inlineCodeForeground)
    result.addAttribute(.font, value: style.fonts.inlineCodeFont)
    if style.useMPTextKit {
      let inlineCodeBorder = MPITextBackground(fill: style.colors.inlineCodeBackground, cornerRadius: 4)
      inlineCodeBorder.insets = UIEdgeInsets(top: 2, left: -2, bottom: 0, right: -2)
      result.addAttribute(.MPIBackground, value: inlineCodeBorder)
    } else {
      result.addAttribute(.backgroundColor, value: style.colors.inlineCodeBackground)
      
    }
    return result
  }
  
  public mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> NSAttributedString {
    
    let code = codeBlock.code.trimmingCharacters(in: .whitespacesAndNewlines)
    let highlight = GMarkCodeHighlight.shared.generateAttributeText(code, language: codeBlock.language ?? "")
    if let h = highlight, !h.string.hasPrefix("undefined")  {
      let hM = NSMutableAttributedString(attributedString: h)
      hM.addAttribute(.font, value: style.codeBlockStyle.font)
      return hM
    }
    
    let result = defaultAttribute(from:  code)
    result.addAttribute(.font, value: style.codeBlockStyle.font)
    result.addAttribute(.foregroundColor, value: style.codeBlockStyle.foregroundColor)
    
    if style.codeBlockStyle.customRender {
      return result
    }
    if style.useMPTextKit {
      let inlineCodeBorder = MPITextBackground(fill: style.codeBlockStyle.backgroundColor, cornerRadius: 4)
      result.addAttribute(.MPIBlockBackground, value: inlineCodeBorder)
    } else {
      result.addAttribute(.backgroundColor, value: style.codeBlockStyle.backgroundColor)
    }
    
    if codeBlock.hasSuccessor {
      result.append(.singleNewline(withStyle: style))
    }
    
    return result
  }
  
  public mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> NSAttributedString {
    let result = defaultAttribute(from: "")
    
    for child in strikethrough.children {
      result.append(visit(child))
    }
    result.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue)
    
    return result
  }
  
  public mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> NSAttributedString {
    
    let result = defaultAttribute(from: "")
    
    let font = style.fonts.current
    
    for listItem in unorderedList.listItems {
      var listItemAttributes: [NSAttributedString.Key: Any] = [:]
      
      let listItemParagraphStyle = NSMutableParagraphStyle()
      
      let baseLeftMargin: CGFloat = 5.0
      let leftMarginOffset = baseLeftMargin + (20.0 * CGFloat(unorderedList.listDepth))
      let spacingFromIndex: CGFloat = 8.0
      let bulletWidth = ceil(NSAttributedString(string: "•", attributes: [.font: font]).size().width)
      let firstTabLocation = leftMarginOffset + bulletWidth
      let secondTabLocation = firstTabLocation + spacingFromIndex
      
      listItemParagraphStyle.tabStops = [
        NSTextTab(textAlignment: .right, location: firstTabLocation),
        NSTextTab(textAlignment: .left, location: secondTabLocation)
      ]
      
      listItemParagraphStyle.headIndent = secondTabLocation
      
      listItemAttributes[.paragraphStyle] = listItemParagraphStyle
      listItemAttributes[.font] = font
      listItemAttributes[.listDepth] = unorderedList.listDepth
      
      let listItemAttributedString = visit(listItem).mutableCopy() as! NSMutableAttributedString
      listItemAttributedString.insert(NSAttributedString(string: "\t•\t", attributes: listItemAttributes), at: 0)
      
      result.append(listItemAttributedString)
    }
    
    if unorderedList.hasSuccessor {
      result.append(.doubleNewline(withStyle: style))
    }
    
    return result
  }
  
  public mutating func visitListItem(_ listItem: ListItem) -> NSAttributedString {
    let result = NSMutableAttributedString()
    
    for child in listItem.children {
      result.append(visit(child))
    }
    
    if listItem.hasSuccessor {
      result.append(.singleNewline(withStyle: style))
    }
    
    return result
  }
  
  public mutating func visitOrderedList(_ orderedList: OrderedList) -> NSAttributedString {
    let result = defaultAttribute(from: "")
    
    for (index, listItem) in orderedList.listItems.enumerated() {
      var listItemAttributes: [NSAttributedString.Key: Any] = [:]
      
      let font = style.fonts.current
      let numeralFont = style.listStyle.bulletFont
      
      let listItemParagraphStyle = NSMutableParagraphStyle()
      
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
        NSTextTab(textAlignment: .left, location: secondTabLocation)
      ]
      
      listItemParagraphStyle.headIndent = secondTabLocation
      
      listItemAttributes[.paragraphStyle] = listItemParagraphStyle
      listItemAttributes[.font] = font
      listItemAttributes[.listDepth] = orderedList.listDepth
      
      let listItemAttributedString = visit(listItem).mutableCopy() as! NSMutableAttributedString
      
      // Same as the normal list attributes, but for prettiness in formatting we want to use the cool monospaced numeral font
      var numberAttributes = listItemAttributes
      numberAttributes[.font] = numeralFont
      
      let numberAttributedString = NSAttributedString(string: "\t\(index + 1).\t", attributes: numberAttributes)
      listItemAttributedString.insert(numberAttributedString, at: 0)
      
      result.append(listItemAttributedString)
    }
    
    if orderedList.hasSuccessor {
      result.append(orderedList.isContainedInList ? .singleNewline(withStyle: style) : .doubleNewline(withStyle: style))
    }
    
    return result
  }
  
  public mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> NSAttributedString {
    let result = NSMutableAttributedString()
    
//    print("blockquote depth: \(blockQuote.quoteDepth)")
    
    let config = BlockQuoteConfig(
      baseLeftMargin: 15.0,
      depthOffset: 20.0,
      maxDepth: 5
    )
    
    for child in blockQuote.children {
      let quoteAttributes = createQuoteAttributes(blockQuote: blockQuote, config: config)
      
      guard let quoteAttributedString = processChild(child, attributes: quoteAttributes, depth: blockQuote.quoteDepth) else {
        print("Warning: Failed to process child element in blockquote")
        continue
      }
      
      applyStyle(to: quoteAttributedString, depth: blockQuote.quoteDepth)
      result.append(quoteAttributedString)
    }
    
    // 只在引用块后面添加一个换行，而不是两个
    if blockQuote.hasSuccessor {
      result.append(blockQuote.isContainedInList ? .singleNewline(withStyle: style) : .doubleNewline(withStyle: style))
    }
    
    return result
  }
  
  private func createQuoteAttributes(blockQuote: BlockQuote, config: BlockQuoteConfig) -> [NSAttributedString.Key: Any] {
    var quoteAttributes: [NSAttributedString.Key: Any] = [:]
    
    let quoteParagraphStyle = NSMutableParagraphStyle()
    
    let effectiveDepth = min(blockQuote.quoteDepth, config.maxDepth)
    let leftMarginOffset = config.baseLeftMargin + (config.depthOffset * CGFloat(effectiveDepth))
    
    quoteParagraphStyle.firstLineHeadIndent = config.baseLeftMargin
    quoteParagraphStyle.headIndent = leftMarginOffset
    
    quoteAttributes[.paragraphStyle] = quoteParagraphStyle
    quoteAttributes[.font] = style.blockquoteStyle.font
    quoteAttributes[.quoteDepth] = blockQuote.quoteDepth
    
    return quoteAttributes
  }
  
  private mutating func processChild(_ child: Markup, attributes: [NSAttributedString.Key: Any], depth: Int) -> NSMutableAttributedString? {
    guard var childAttributedString = visit(child) as? NSMutableAttributedString else {
      return nil
    }
    
    // 在每一段的开头添加引用标记
    let range = NSRange(location: 0, length: childAttributedString.length)
    childAttributedString.enumerateAttribute(.paragraphStyle, in: range, options: []) { (value, range, stop) in
      if range.location == 0 || (range.location > 0 && childAttributedString.string[childAttributedString.string.index(before: childAttributedString.string.index(childAttributedString.string.startIndex, offsetBy: range.location))] == "\n") {
        let quoteMarker = NSAttributedString(string: "   ", attributes: attributes)
        childAttributedString.insert(quoteMarker, at: range.location)
      }
    }
    
    return childAttributedString
  }
  
  private func applyStyle(to attributedString: NSMutableAttributedString, depth: Int) {
    attributedString.addAttribute(.foregroundColor, value: style.blockquoteStyle.textColor)
    
    if style.useMPTextKit {
      let quoteBorder = MPITextBackground(fill: style.blockquoteStyle.backgroundColor, cornerRadius: 0)
      quoteBorder.borderEdges = .left
      quoteBorder.borderColor = style.blockquoteStyle.borderColor
      quoteBorder.borderWidth = style.blockquoteStyle.borderWidth
      attributedString.addAttribute(.MPIBlockBackground, value: quoteBorder)
    } else {
      // 使用半透明背景色，确保文本可见
      let backgroundColor = style.blockquoteStyle.backgroundColor.withAlphaComponent(0.1)
      attributedString.addAttribute(.backgroundColor, value: backgroundColor)
    }
  }
  
  struct BlockQuoteConfig {
    let baseLeftMargin: CGFloat
    let depthOffset: CGFloat
    let maxDepth: Int
  }
  /**
   Visit a `InlineHTML` element and return the result.
   
   - parameter inlineHTML: An `InlineHTML` element.
   - returns: The result of the visit.
   */
  mutating public func visitInlineHTML(_ inlineHTML: InlineHTML) -> Result {
    
    if inlineHTML.plainText == "<LaTex>" {
      beginLatex = true
    } else if inlineHTML.plainText == "</LaTex>" {
      beginLatex = false
    } else if inlineHTML.plainText == "<br>" {
      return .singleNewline(withStyle: style)
    }
    
    return defaultVisit(inlineHTML)
  }
  
  mutating public func visitHTMLBlock(_ html: HTMLBlock) -> Result {
    
    print(html.rawHTML)
    let opt: [NSAttributedString.DocumentReadingOptionKey : Any] = [
      .documentType: NSAttributedString.DocumentType.html,
      .characterEncoding: String.Encoding.utf8.rawValue
    ]
    
    let data = html.rawHTML.data(using: String.Encoding.utf8)!
    
    guard let returnString = try? NSMutableAttributedString(data:data, options: opt, documentAttributes:nil) else {
      return defaultAttribute(from: html.rawHTML)
    }
    if html.hasSuccessor {
      returnString.append(html.isContainedInList ? .singleNewline(withStyle: style) : .doubleNewline(withStyle: style))
    }
    return returnString
    
  }
  
  /**
   Visit a `LineBreak` element and return the result.
   
   - parameter lineBreak: An `LineBreak` element.
   - returns: The result of the visit.
   */
  mutating public func visitLineBreak(_ lineBreak: LineBreak) -> NSAttributedString {
    return defaultAttribute(from: lineBreak.plainText)
  }
  
  /**
   Visit a `SoftBreak` element and return the result.
   
   - parameter softBreak: An `SoftBreak` element.
   - returns: The result of the visit.
   */
  mutating public func visitSoftBreak(_ softBreak: SoftBreak) -> NSAttributedString {
    return NSAttributedString.singleNewline(withStyle: style)
  }
  
  
}

extension GMarkupVisitor {
  
  func defaultAttribute(from text: String) -> NSMutableAttributedString {
    
    let attributedString = NSMutableAttributedString(string: text)
    
    var attributes: [NSAttributedString.Key: Any] = [:]
    
    attributes[.font] = style.fonts.current
    attributes[.foregroundColor] = style.colors.current
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.minimumLineHeight = style.paragraphStyle.lineSpacing
    attributes[.paragraphStyle] = paragraphStyle
    attributedString.addAttributes(attributes, range: NSRange(location: 0, length: text.utf16.count))
    
    return attributedString
  }
  
}

extension ListItemContainer {
  /// Depth of the list if nested within others. Index starts at 0.
  var listDepth: Int {
    var index = 0
    
    var currentElement = parent
    
    while currentElement != nil {
      if currentElement is ListItemContainer {
        index += 1
      }
      
      currentElement = currentElement?.parent
    }
    
    return index
  }
}

extension BlockQuote {
  /// Depth of the quote if nested within others. Index starts at 0.
  var quoteDepth: Int {
    var index = 0
    
    var currentElement = parent
    
    while currentElement != nil {
      if currentElement is BlockQuote {
        index += 1
      }
      
      currentElement = currentElement?.parent
    }
    
    return index
  }
}

extension NSAttributedString.Key {
  static let listDepth = NSAttributedString.Key("ListDepth")
  static let quoteDepth = NSAttributedString.Key("QuoteDepth")
}

extension NSMutableAttributedString {
  
  func addAttribute(_ name: NSAttributedString.Key, value: Any) {
    addAttribute(name, value: value, range: NSRange(location: 0, length: length))
  }
  
  func addAttributes(_ attrs: [NSAttributedString.Key : Any]) {
    addAttributes(attrs, range: NSRange(location: 0, length: length))
  }
}

extension Markup {
  /// Returns true if this element has sibling elements after it.
  var hasSuccessor: Bool {
    guard let childCount = parent?.childCount else { return false }
    let temp = indexInParent < childCount - 1
    if temp {
      if let markup = parent?.child(at: indexInParent+1) {
        if isSplitPoint(markup) {
          return false
        }
      }
    }
    return temp
  }
  
  func isSplitPoint(_ item: Any) -> Bool {
    return item is Table || item is CodeBlock || item is ThematicBreak
  }
  
  var isContainedInList: Bool {
    var currentElement = parent
    
    while currentElement != nil {
      if currentElement is ListItemContainer {
        return true
      }
      
      currentElement = currentElement?.parent
    }
    
    return false
  }
}

// MARK: - Extensions Land

extension NSMutableAttributedString {
  func applyEmphasis() {
    enumerateAttribute(.font, in: NSRange(location: 0, length: length), options: []) { value, range, stop in
      guard let font = value as? UIFont else { return }
      
      let newFont = font.apply(newTraits: .traitItalic)
      addAttribute(.font, value: newFont, range: range)
    }
  }
  
  func applyStrong() {
    enumerateAttribute(.font, in: NSRange(location: 0, length: length), options: []) { value, range, stop in
      guard let font = value as? UIFont else { return }
      
      let newFont = font.apply(newTraits: .traitBold)
      addAttribute(.font, value: newFont, range: range)
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

extension UIFont {
  func apply(newTraits: UIFontDescriptor.SymbolicTraits, newPointSize: CGFloat? = nil) -> UIFont {
    var existingTraits = fontDescriptor.symbolicTraits
    existingTraits.insert(newTraits)
    
    guard let newFontDescriptor = fontDescriptor.withSymbolicTraits(existingTraits) else { return self }
    return UIFont(descriptor: newFontDescriptor, size: newPointSize ?? pointSize)
  }
}

