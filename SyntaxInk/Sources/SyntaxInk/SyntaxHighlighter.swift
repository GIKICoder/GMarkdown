import Foundation

/// A syntax highlighter.
public struct SyntaxHighlighter<
    Grammar: SyntaxInk.Grammar,
    Theme: SyntaxInk.Theme
>: Sendable where Theme.Token == Grammar.Token {
    private let grammar: Grammar
    private let theme: Theme

    public init(grammar: Grammar, theme: Theme) {
        self.grammar = grammar
        self.theme = theme
    }

    /// Highlights the given code and returns `NSAttributedString`.
    public func highlight(_ code: String) -> NSAttributedString {
        let tokens = grammar.tokenize(code)
        let attributedStrings = tokens.map { theme.attributes(for: $0) }
        let result = NSMutableAttributedString()
        for attributedString in attributedStrings {
            result.append(attributedString)
        }
        return result
    }
}
