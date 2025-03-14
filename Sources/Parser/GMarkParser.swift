//
//  GMarkParser.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/25.
//

import Foundation
import Markdown

public class GMarkParser {
    public init() {
        // 初始化代码
    }

    public func parseMarkdownToMarkups(markdown: String) -> [Markup] {
        let source = markdown
        let document = parseMarkdown(from: source)
        let nodes = convertMarkups(document)
        return nodes
    }

    public func parseMarkdown(from markdown: String) -> Document {
        let source = markdown
        let process = preprocessing(source)
        let document = Document(parsing: process)
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

    /// preprocess Latex
    public func preprocessing(_ markdown: String) -> String {
        var result = markdown
        // \\$\\$(.+?)\\$\\$|\\$(.+?)\\$|
        /// |\\\\\\[\n(.+?)\\\\\\\n]
        //       let pattern = "\\\\\\[(.+?)\\\\\\]|\\\\\\((.+?)\\\\\\)"
        // let pattern = "\\\\\\[((?:.|\\n)+?)\\\\\\]|\\\\\\(((?:.|\\n)+?)\\\\\\)"
        let pattern = "\\$\\$(.+?)\\$\\$|\\$(.+?)\\$|\\\\\\[((?:.|\\n)+?)\\\\\\]|\\\\\\(((?:.|\\n)+?)\\\\\\)"

        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let nsString = result as NSString
        let range = NSRange(location: 0, length: nsString.length)

        let matches = regex.matches(in: result, options: [], range: range).reversed()

        for match in matches {
            let matchRange = match.range
            let matchedString = nsString.substring(with: matchRange)
            if matchedString.count < 3000 {
                let lines = matchedString.components(separatedBy: .newlines)
                if lines.count > 1 {
                    /// Add a safeguard.
                    let wrappedString = "\n <LaTex>\(matchedString)</LaTex> \n"
                    result = (result as NSString).replacingCharacters(in: matchRange, with: wrappedString)
                } else {
                    let wrappedString = "<LaTex>\(matchedString)</LaTex>"
                    result = (result as NSString).replacingCharacters(in: matchRange, with: wrappedString)
                }
                
            } else {
                
            }
        }
        /// Ensure that each code block image stands alone on a separate line.
        result = replaceSubstring(in: result, target: "```", replacement: "\n```")
        
        result = replaceSubstring(in: result, target: "<img>", replacement: "\n\n ![](")
        result = replaceSubstring(in: result, target: "</img>", replacement: ") \n\n")
        
        
        return result
    }

    func replaceSubstring(in originalString: String, target: String, replacement: String) -> String {
        let resultString = originalString.replacingOccurrences(of: target, with: replacement)
        return resultString
    }
}
