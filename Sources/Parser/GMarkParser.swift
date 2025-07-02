//
//  GMarkParser.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/25.
//

import Foundation
import Markdown

public class GMarkParser {
    
    private let preprocessor: GMarkPreprocessor
    
    public init(preprocessor: GMarkPreprocessor? = nil) {
        self.preprocessor = preprocessor ?? GMarkPreprocessor()
    }

    public func parseMarkdownToMarkups(markdown: String) -> [Markup] {
        let document = parseMarkdown(from: markdown)
        let nodes = convertMarkups(document)
        return nodes
    }

    public func parseMarkdown(from markdown: String) -> Document {
        let processedMarkdown = preprocessor.process(markdown)
        let document = Document(parsing: processedMarkdown)
        
        #if DEBUG
            print(document.debugDescription())
        #endif
        
        return document
    }

    public func convertMarkups(_ node: Markup) -> [Markup] {
        let markups = node.children.reduce(into: [Markup]()) { result, item in
            result.append(item)
        }
        return markups
    }
    
    // MARK: - Preprocessor Management
    
    /// Add a custom preprocessor
    public func addPreprocessor(_ processor: GMarkPreprocessorProtocol) {
        preprocessor.addProcessor(processor)
    }
    
    /// Remove a preprocessor by type
    public func removePreprocessor<T: GMarkPreprocessorProtocol>(ofType type: T.Type) {
        preprocessor.removeProcessor(ofType: type)
    }
}
