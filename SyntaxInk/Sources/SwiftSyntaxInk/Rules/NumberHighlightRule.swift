import Foundation
import SwiftSyntax

public struct NumberHighlightRule: SwiftSyntaxHighlightRule {
    public var configuration: SwiftTheme.Configuration

    public init(configuration: SwiftTheme.Configuration) {
        self.configuration = configuration
    }

    public func attributes(for token: TokenSyntax) -> NSAttributedString? {
        switch token.tokenKind {
        case .integerLiteral, .floatLiteral:
            return NSAttributedString(
                string: token.text,
                attributes: configuration.style(for: .numbers).attributes
            )
        default:
            return nil
        }
    }
}
