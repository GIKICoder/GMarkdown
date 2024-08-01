//
//  GMarkParser.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/25.
//

import Foundation
import Markdown


public class GMarkParser {
  
  func parseMarkdownToMarkups(markdown: String) -> [Markup] {
    let source = markdown
    let document = parseMarkdown(from: source)
    let nodes = convertMarkups(document)
    return nodes
  }
  
  func parseMarkdown(from markdown: String) -> Document {
    let source = markdown
    let process = preprocessing(source)
    let document = Document(parsing: process)
    print(document.debugDescription())
    return document
  }
  
  func convertMarkups(_ node: Markup) -> [Markup] {
    let markups = node.children.reduce(into: [Markup]()) { result, item in
      result.append(item)
    }
    print("markups: \(markups)")
    return markups
  }
  
  /// preprocess Latex
  func preprocessing(_ markdown: String) -> String {
    let pattern = "\\$\\$(.+?)\\$\\$|\\$(.+?)\\$|\\\\\\[(.+?)\\\\\\]|\\\\\\((.+?)\\\\\\)"
    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    let nsString = markdown as NSString
    let range = NSRange(location: 0, length: nsString.length)
    
    var result = markdown
    let matches = regex.matches(in: markdown, options: [], range: range).reversed()
    
    for match in matches {
      let matchRange = match.range
      let matchedString = nsString.substring(with: matchRange)
      let wrappedString = "<LaTex>\(matchedString)</LaTex>"
      result = (result as NSString).replacingCharacters(in: matchRange, with: wrappedString)
    }
    return result
  }
  
  func split(_ node: Markup) -> [[Markup]] {
    let splitLists = node.children.reduce(into: [[Markup]]()) { result, item in
      switch item {
      case is Table, is CodeBlock: ///, is BlockQuote, is ThematicBreak
        result.append([item])
      default:
        if result.isEmpty || isSplitPoint(result.last!.last!) {
          result.append([item])
        } else {
          result[result.count - 1].append(item)
        }
      }
    }
    //print("Split lists: \(splitLists)")
    return splitLists
  }
  
  func isSplitPoint(_ item: Any) -> Bool {
    return item is Table || item is CodeBlock
  }
}

