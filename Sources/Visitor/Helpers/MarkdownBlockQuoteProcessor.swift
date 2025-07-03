//
//  MarkdownBlockQuoteProcessor.swift
//  GMarkdown
//
//  Created by 巩柯 on 2025/7/4.
//

import Foundation
import UIKit
import Markdown

// MARK: - Block Quote Processor
public struct MarkdownBlockQuoteProcessor {
    
    // MARK: - Configuration
    public struct Config {
        public let baseLeftMargin: CGFloat
        public let depthOffset: CGFloat
        public let maxDepth: Int
        
        public init(baseLeftMargin: CGFloat = 15.0,
                    depthOffset: CGFloat = 20.0,
                    maxDepth: Int = 5) {
            self.baseLeftMargin = baseLeftMargin
            self.depthOffset = depthOffset
            self.maxDepth = maxDepth
        }
        
        public static let `default` = Config()
    }
    
    // MARK: - Static Methods
    public static func processBlockQuote(_ blockQuote: BlockQuote,
                                         style:Style,
                                         visitor: (any MarkupVisitor),
                                       config: Config = .default) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        
        for child in blockQuote.children {
            let attributes = createBlockQuoteAttributes(
                depth: blockQuote.quoteDepth,
                config: config,
                style: style
            )
            
            if let childAttributed = processBlockQuoteChild(
                child,
                attributes: attributes,
                style: style,
                visitor: visitor
            ) {
                attributedString.append(childAttributed)
            }
        }
        
        if blockQuote.hasSuccessor {
            attributedString.append(blockQuote.isContainedInList
                ? .singleNewline(withStyle: style)
                : .doubleNewline(withStyle: style))
        }
        
        return attributedString
    }
    
    // MARK: - Private Static Methods
    private static func createBlockQuoteAttributes(depth: Int,
                                                  config: Config,
                                                  style: Style) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        let paragraphStyle = NSMutableParagraphStyle()
        
        let effectiveDepth = min(depth, config.maxDepth)
        let leftIndent = config.baseLeftMargin + (config.depthOffset * CGFloat(effectiveDepth))
        
        paragraphStyle.firstLineHeadIndent = leftIndent
        paragraphStyle.headIndent = leftIndent
        paragraphStyle.lineSpacing = max(5, 25 - style.fonts.current.pointSize)
        paragraphStyle.paragraphSpacing = 16
        
        attributes[.paragraphStyle] = paragraphStyle
        attributes[.font] = style.blockquoteStyle.font
        attributes[.foregroundColor] = style.blockquoteStyle.textColor
        attributes[.quoteDepth] = depth
        
        return attributes
    }
    
    private static func processBlockQuoteChild(_ child: Markup,
                                             attributes: [NSAttributedString.Key: Any],
                                               style:Style,
                                               visitor: any MarkupVisitor) -> NSMutableAttributedString? {
        var mutableVisitor = visitor
        guard let childAttributed = mutableVisitor.visit(child) as? NSMutableAttributedString else { return nil }
        
        let range = NSRange(location: 0, length: childAttributed.length)
        childAttributed.addAttributes(attributes, range: range)
        
        MarkdownStyleProcessor.applyQuoteStyle(to: childAttributed, style: style)
        return childAttributed
    }
}

