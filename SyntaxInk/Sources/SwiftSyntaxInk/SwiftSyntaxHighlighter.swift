import SyntaxInk
import SwiftUI

public typealias SwiftSyntaxHighlighter = SyntaxHighlighter<SwiftGrammar, SwiftTheme>

extension SwiftSyntaxHighlighter {
    public init(theme: SwiftTheme = .default) {
        self.init(grammar: SwiftGrammar(), theme: theme)
    }
}

extension SwiftUI.Color {
    /// The background for default light theme of Xcode.
    public static let xcodeBackgroundDefaultColor = Color(red: 1, green: 1, blue: 1)

    /// The background for default dark theme of Xcode.
    public static let xcodeBackgroundDefaultDarkColor = Color(
        red: 41 / 255.0,
        green: 42 / 255.0,
        blue: 47 / 255.0
    )
}
