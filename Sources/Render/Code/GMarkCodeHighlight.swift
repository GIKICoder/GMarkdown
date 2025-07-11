//
//  GMarkCodeHighlight.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/26.
//

import Foundation
import Syntect
import SyntaxInk

open class GMarkCodeHighlight: NSObject {
    override init() {
        highlightr?.setTheme(to: "github-gist")
    }

    /// Highlightr instance used internally for highlighting. Use this for configuring the theme.
    public let highlightr = Highlightr()

    /// Shared instance of CodeHighlightShared
    public static let shared = GMarkCodeHighlight()
    let syntaxInk = UniversalSyntaxInk()
    public func changeDark(_ dark: Bool) {
        let theme = dark ? "dark" : "github-gist"
        setTheme(to: theme)
    }

    public func setTheme(to name: String) {
        highlightr?.setTheme(to: name)
    }
    
    public func generateAttributeText(_ string: String, language: String) -> NSAttributedString? {
        
//        let syntax = Syntect.shared
//        let highlighted2 = syntax.highlight(string, language: language)
//        return highlighted2
        print("开始语法高亮处理 - 语言: \(language), 字符串长度: \(string.count)")
         
         // 记录 syntaxInk.highlight 的耗时
         let startTime1 = CFAbsoluteTimeGetCurrent()
         let highlighted = syntaxInk.highlight(string, language: language)
//         let highlightedTextslow = highlightr?.highlight(string, as: language, fastRender: false)
         let endTime1 = CFAbsoluteTimeGetCurrent()
         let duration1 = endTime1 - startTime1
         print("✅ syntaxInk.highlight 耗时: \(String(format: "%.4f", duration1)) 秒")
         
         // 记录 highlightr?.highlight 的耗时
         let startTime2 = CFAbsoluteTimeGetCurrent()
         let highlightedText = highlightr?.highlight(string, as: language, fastRender: true)
         let endTime2 = CFAbsoluteTimeGetCurrent()
         let duration2 = endTime2 - startTime2
         print("✅ highlightr.highlight 耗时: \(String(format: "%.4f", duration2)) 秒")
         
         // 性能对比
         let faster = duration1 < duration2 ? "syntaxInk" : "highlightr"
         let ratio = max(duration1, duration2) / min(duration1, duration2)
         print("📊 性能对比: \(faster) 更快，快了 \(String(format: "%.2f", ratio)) 倍")
        return highlighted
        
//        return highlighted
    }
}
