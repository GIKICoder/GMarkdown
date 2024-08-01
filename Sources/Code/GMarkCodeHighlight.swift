//
//  GMarkCodeHighlight.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/26.
//

import Foundation
import Highlightr

open class GMarkCodeHighlight : NSObject {
    /// Highlightr instance used internally for highlighting. Use this for configuring the theme.
    public let highlightr = Highlightr()

    /// Shared instance of CodeHighlightShared
    public static let shared = GMarkCodeHighlight()

    public func generateAttributeText(_ string: String, language: String) -> NSAttributedString? {
        let highlightedText = highlightr?.highlight(string, as: language)
        return highlightedText
    }
}
