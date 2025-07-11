import Foundation
import SwiftSyntax

public struct StringHighlightRule: SwiftSyntaxHighlightRule {
    public var configuration: SwiftTheme.Configuration
    
    public init(configuration: SwiftTheme.Configuration) {
        self.configuration = configuration
    }
    
    public func attributes(for token: TokenSyntax) -> NSAttributedString? {
        switch token.tokenKind {
        case .stringSegment, .multilineStringQuote, .stringQuote:
            return NSAttributedString(
                string: token.text,
                attributes: configuration.style(for: .string).attributes
            )
        default:
            return nil
        }
    }
}
