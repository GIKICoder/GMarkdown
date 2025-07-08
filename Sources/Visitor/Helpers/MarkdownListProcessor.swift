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
    
    // MARK: - Public Static Methods
    
    public static func processOrderedList(_ orderedList: OrderedList,
                                        style: Style,
                                        visitor: inout any MarkupVisitor) -> NSMutableAttributedString {
        let result = MarkdownStyleProcessor.buildDefaultAttributedString(from: "", style: style)
        
        for (index, listItem) in orderedList.listItems.enumerated() {
            let listItemString = createOrderedListItemString(
                listItem: listItem,
                index: index,
                orderedList: orderedList,
                style: style,
                visitor: &visitor
            )
            result.append(listItemString)
        }
        
    
        return result
    }
    
    public static func processUnorderedList(_ unorderedList: UnorderedList,
                                          style: Style,
                                          visitor: inout any MarkupVisitor) -> NSMutableAttributedString {
        let result = MarkdownStyleProcessor.buildDefaultAttributedString(from: "", style: style)
        
        for listItem in unorderedList.listItems {
            let listItemString = createUnorderedListItemString(
                listItem: listItem,
                depth: unorderedList.listDepth,
                style: style,
                visitor: &visitor
            )
            result.append(listItemString)
        }
        return result
    }
    
    // MARK: - Private Static Methods
    
    private static func createOrderedListItemString(listItem: ListItem,
                                                  index: Int,
                                                  orderedList: OrderedList,
                                                  style: Style,
                                                  visitor: inout any MarkupVisitor) -> NSAttributedString {
        
        let listItemAttributedString = (visitor.visit(listItem) as AnyObject).mutableCopy() as! NSMutableAttributedString
        
        let isRTL = TextDirectionDetector.isRTLLanguage(text: listItemAttributedString.string)
        
        let listItemAttributes = createListItemAttributes(
            depth: orderedList.listDepth,
            isRTL: isRTL,
            isOrdered: true,
            highestNumber: orderedList.childCount,
            style: style
        )
        
        let numberPrefix = createOrderedListPrefix(
            index: index,
            startIndex: orderedList.startIndex,
            isRTL: isRTL,
            attributes: listItemAttributes,
            style: style
        )
        
        listItemAttributedString.insert(numberPrefix, at: 0)
        return listItemAttributedString
    }
    
    private static func createUnorderedListItemString(listItem: ListItem,
                                                    depth: Int,
                                                    style: Style,
                                                    visitor: inout any MarkupVisitor) -> NSAttributedString {
        let listItemAttributedString = (visitor.visit(listItem) as AnyObject).mutableCopy() as! NSMutableAttributedString
        let isRTL = TextDirectionDetector.isRTLLanguage(text: listItemAttributedString.string)
        
        let bulletSymbol = getBulletSymbol(for: listItem)
        
        let listItemAttributes = createListItemAttributes(
            depth: depth,
            isRTL: isRTL,
            isOrdered: false,
            bulletSymbol: bulletSymbol,
            style: style
        )
        
        let bulletPrefix = createBulletPrefix(
            symbol: bulletSymbol,
            isRTL: isRTL,
            attributes: listItemAttributes
        )
        
        listItemAttributedString.insert(bulletPrefix, at: 0)
        return listItemAttributedString
    }
    
    private static func getBulletSymbol(for listItem: ListItem) -> String {
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
    
    private static func createListItemAttributes(depth: Int,
                                               isRTL: Bool,
                                               isOrdered: Bool,
                                               highestNumber: Int = 0,
                                               bulletSymbol: String = "•",
                                               style: Style) -> [NSAttributedString.Key: Any] {
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
    
    private static func createOrderedListPrefix(index: Int,
                                              startIndex: UInt,
                                              isRTL: Bool,
                                              attributes: [NSAttributedString.Key: Any],
                                              style: Style) -> NSAttributedString {
        var numberAttributes = attributes
        numberAttributes[.font] = style.listStyle.bulletFont
        numberAttributes[.foregroundColor] = style.colors.current
        
        let taps = isRTL ? " " : "\t"
        let number = Int(startIndex) > 0 ? Int(startIndex) + index : index + 1
        return NSAttributedString(string: "\t\(number).\(taps)", attributes: numberAttributes)
    }
    
    private static func createBulletPrefix(symbol: String,
                                         isRTL: Bool,
                                         attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let taps = isRTL ? " " : "\t"
        return NSAttributedString(string: "\t\(symbol)\(taps)", attributes: attributes)
    }
}
