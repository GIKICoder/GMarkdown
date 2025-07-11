import Foundation

/// A protocol for a grammar.
public protocol Grammar: Sendable {

    /// A token in this grammar.
    associatedtype Token: Sendable

    /// Tokenizes the given code.
    func tokenize(_ code: String) -> [Token]
}
