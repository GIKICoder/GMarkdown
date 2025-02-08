//
//  GMarkCodeHighlight.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/26.
//

import Foundation

open class GMarkCodeHighlight: NSObject {
    override init() {
        highlightr?.setTheme(to: "github-gist")
    }

    /// Highlightr instance used internally for highlighting. Use this for configuring the theme.
    public let highlightr = Highlightr()

    /// Shared instance of CodeHighlightShared
    public static let shared = GMarkCodeHighlight()
    
    public func changeDark(_ dark: Bool) {
        let theme = dark ? "dark" : "github-gist"
        setTheme(to: theme)
    }

    public func setTheme(to name: String) {
        highlightr?.setTheme(to: name)
    }
    
    public func generateAttributeText(_ string: String, language: String) -> NSAttributedString? {
        let highlightedText = highlightr?.highlight(string, as: language, fastRender: true)
        return highlightedText
    }
}
