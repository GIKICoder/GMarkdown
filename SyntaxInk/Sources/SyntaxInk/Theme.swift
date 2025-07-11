import Foundation

/// A theme of a syntax highlighter.
public protocol Theme: Sendable {

    /// A token for this theme.
    associatedtype Token: Sendable

    /// Gets `NSAttributedString` for the given token.
    func attributes(for token: Token) -> NSAttributedString
}
