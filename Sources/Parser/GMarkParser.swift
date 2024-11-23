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
        //        print("markups: \(markups)")
        return markups
    }

    /// preprocess Latex
    public func preprocessing(_ markdown: String) -> String {
        var result = markdown
        // \\$\\$(.+?)\\$\\$|\\$(.+?)\\$|
        /// |\\\\\\[\n(.+?)\\\\\\\n]
        //       let pattern = "\\\\\\[(.+?)\\\\\\]|\\\\\\((.+?)\\\\\\)"

        let pattern = "\\\\\\[((?:.|\\n)+?)\\\\\\]|\\\\\\(((?:.|\\n)+?)\\\\\\)"

        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let nsString = result as NSString
        let range = NSRange(location: 0, length: nsString.length)

        let matches = regex.matches(in: result, options: [], range: range).reversed()

        for match in matches {
            let matchRange = match.range
            let matchedString = nsString.substring(with: matchRange)
            if matchedString.count < 300 {
                /// 加个保护. 超过300 默认不匹配
                let wrappedString = "<LaTex>\(matchedString)</LaTex>"
                result = (result as NSString).replacingCharacters(in: matchRange, with: wrappedString)
            } else {
                print("asdfsda")
            }
        }

        result = replaceSubstring(in: result, target: "<img>", replacement: "\n ![](")
        result = replaceSubstring(in: result, target: "</img>", replacement: ") \n")
        
        /// <dotline-card-type>
        result = replaceSubstring(in: result, target: "<dotline-card-type>", replacement: "\n<dotline-card-type>")
        result = replaceSubstring(in: result, target: "</dotline-card-type>", replacement: "</dotline-card-type>\n")
        /// <dotline-summary>
        result = replaceSubstring(in: result, target: "<dotline-summary>", replacement: "\n<dotline-summary>")
        result = replaceSubstring(in: result, target: "</dotline-summary>", replacement: "</dotline-summary>\n")
        
        
        /// <dotline-card-title>
        result = replaceSubstring(in: result, target: "<dotline-card-title>", replacement: "\n<dotline-card-title>")
        result = replaceSubstring(in: result, target: "</dotline-card-title>", replacement: "</dotline-card-title>\n")
        
        /// <dotline-highlight>
        result = replaceSubstring(in: result, target: "<dotline-highlight>", replacement: "\n<dotline-highlight>")
        result = replaceSubstring(in: result, target: "</dotline-highlight>", replacement: "</dotline-highlight>\n")
        
        /// <dotline-card-images>
        result = replaceSubstring(in: result, target: "<dotline-card-images>", replacement: "\n<dotline-card-images>")
        result = replaceSubstring(in: result, target: "</dotline-card-images>", replacement: "</dotline-card-images>\n")
        
        return result
    }

    func replaceSubstring(in originalString: String, target: String, replacement: String) -> String {
        let resultString = originalString.replacingOccurrences(of: target, with: replacement)
        return resultString
    }

    func split(_ node: Markup) -> [[Markup]] {
        let splitLists = node.children.reduce(into: [[Markup]]()) { result, item in
            switch item {
            case is Table, is CodeBlock: /// , is BlockQuote, is ThematicBreak
                result.append([item])
            default:
                if result.isEmpty || isSplitPoint(result.last!.last!) {
                    result.append([item])
                } else {
                    result[result.count - 1].append(item)
                }
            }
        }
        // print("Split lists: \(splitLists)")
        return splitLists
    }

    public func isSplitPoint(_ item: Any) -> Bool {
        return item is Table || item is CodeBlock
    }
}
