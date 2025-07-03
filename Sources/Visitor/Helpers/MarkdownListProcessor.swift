//
//  MarkdownListProcessor.swift
//  GMarkdown
//
//  Created by 巩柯 on 2025/7/3.
//

import Foundation
import UIKit
import Markdown


// MARK: - List Processor
public struct MarkdownListProcessor {
    
    public let style: Style
    public var visitor: any MarkupVisitor
    
    public init(style: Style,
                visitor: any MarkupVisitor) {
        self.style = style
        self.visitor = visitor
    }
    
    // MARK: - Public Methods
    
    public mutating func processOrderedList(_ orderedList: OrderedList) -> NSAttributedString {
        let result = MarkdownStyleProcessor.buildDefaultAttributedString(from: "", style: style)
        
        for (index, listItem) in orderedList.listItems.enumerated() {
            let listItemString = createOrderedListItemString(
                listItem: listItem,
                index: index,
                orderedList: orderedList
            )
            result.append(listItemString)
        }
        
        if orderedList.hasSuccessor {
            result.append(orderedList.isContainedInList
                ? .singleNewline(withStyle: style)
                : .doubleNewline(withStyle: style))
        }
        
        return result
    }
    
    public mutating func processUnorderedList(_ unorderedList: UnorderedList) -> NSAttributedString {
        let result = MarkdownStyleProcessor.buildDefaultAttributedString(from: "", style: style)
        
        for listItem in unorderedList.listItems {
            let listItemString = createUnorderedListItemString(
                listItem: listItem,
                depth: unorderedList.listDepth
            )
            result.append(listItemString)
        }
        
        if unorderedList.hasSuccessor {
            result.append(.doubleNewline(withStyle: style))
        }
        
        return result
    }
    
    // MARK: - Private Methods
    
    private mutating func createOrderedListItemString(listItem: ListItem,
                                           index: Int,
                                           orderedList: OrderedList) -> NSAttributedString {
        
        let listItemAttributedString = (visitor.visit(listItem) as AnyObject).mutableCopy() as! NSMutableAttributedString
        
        let isRTL = TextDirectionDetector.isRTLLanguage(text: listItemAttributedString.string)
        
        let listItemAttributes = createListItemAttributes(
            depth: orderedList.listDepth,
            isRTL: isRTL,
            isOrdered: true,
            highestNumber: orderedList.childCount
        )
        
        let numberPrefix = createOrderedListPrefix(
            index: index,
            startIndex: orderedList.startIndex,
            isRTL: isRTL,
            attributes: listItemAttributes
        )
        
        listItemAttributedString.insert(numberPrefix, at: 0)
        return listItemAttributedString
    }
    
    private mutating func createUnorderedListItemString(listItem: ListItem,
                                             depth: Int) -> NSAttributedString {
        let listItemAttributedString = (visitor.visit(listItem) as AnyObject).mutableCopy() as! NSMutableAttributedString
        let isRTL = TextDirectionDetector.isRTLLanguage(text: listItemAttributedString.string)
        
        let bulletSymbol = getBulletSymbol(for: listItem)
        
        let listItemAttributes = createListItemAttributes(
            depth: depth,
            isRTL: isRTL,
            isOrdered: false,
            bulletSymbol: bulletSymbol
        )
        
        let bulletPrefix = createBulletPrefix(
            symbol: bulletSymbol,
            isRTL: isRTL,
            attributes: listItemAttributes
        )
        
        listItemAttributedString.insert(bulletPrefix, at: 0)
        return listItemAttributedString
    }
    
    private func getBulletSymbol(for listItem: ListItem) -> String {
        if let checkBox = listItem.checkbox {
            switch checkBox {
            case .checked:
                return "☑"
            case .unchecked:
                return "☐"
            }
        } else {
            return "•"
        }
    }
    
    private func createListItemAttributes(depth: Int,
                                        isRTL: Bool,
                                        isOrdered: Bool,
                                        highestNumber: Int = 0,
                                        bulletSymbol: String = "•") -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        let paragraphStyle = NSMutableParagraphStyle()
        
        let font = style.fonts.current
        paragraphStyle.lineSpacing = 25 - font.pointSize
        paragraphStyle.paragraphSpacing = 14
        paragraphStyle.baseWritingDirection = isRTL ? .rightToLeft : .leftToRight
        paragraphStyle.alignment = isRTL ? .right : .left
        
        let baseLeftMargin: CGFloat = 5.0
        let leftMarginOffset = baseLeftMargin + (20.0 * CGFloat(depth))
        let spacingFromIndex: CGFloat = 8.0
        
        let markerWidth: CGFloat
        if isOrdered {
            let numeralFont = style.listStyle.bulletFont
            markerWidth = ceil(NSAttributedString(string: "\(highestNumber).",
                                                 attributes: [.font: numeralFont]).size().width)
        } else {
            markerWidth = ceil(NSAttributedString(string: bulletSymbol,
                                                 attributes: [.font: font]).size().width)
        }
        
        let firstTabLocation = leftMarginOffset + markerWidth
        let secondTabLocation = firstTabLocation + spacingFromIndex
        
        paragraphStyle.tabStops = [
            NSTextTab(textAlignment: .right, location: firstTabLocation),
            NSTextTab(textAlignment: .left, location: secondTabLocation),
        ]
        
        paragraphStyle.headIndent = secondTabLocation
        
        attributes[.paragraphStyle] = paragraphStyle
        attributes[.font] = font
        attributes[.foregroundColor] = style.colors.current
        attributes[.listDepth] = depth
        
        return attributes
    }
    
    private func createOrderedListPrefix(index: Int,
                                       startIndex: UInt,
                                       isRTL: Bool,
                                       attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        var numberAttributes = attributes
        numberAttributes[.font] = style.listStyle.bulletFont
        numberAttributes[.foregroundColor] = style.colors.current
        
        let taps = isRTL ? " " : "\t"
        let number = Int(startIndex) > 0 ? Int(startIndex) + index : index + 1
        return NSAttributedString(string: "\t\(number).\(taps)", attributes: numberAttributes)
    }
    
    private func createBulletPrefix(symbol: String,
                                  isRTL: Bool,
                                  attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let taps = isRTL ? " " : "\t"
        return NSAttributedString(string: "\t\(symbol)\(taps)", attributes: attributes)
    }
}
