import Foundation
import SwiftSyntax

public struct ClassAndTypeNameHighlightRule: SwiftSyntaxHighlightRule {
    public var configuration: SwiftTheme.Configuration
    
    public init(configuration: SwiftTheme.Configuration) {
        self.configuration = configuration
    }
    
    public func attributes(for token: TokenSyntax) -> NSAttributedString? {
        guard token.parent?.is(IdentifierTypeSyntax.self) ?? false else { return nil }
        return NSAttributedString(
            string: token.text,
            attributes: configuration.style(for: .otherTypeNames).attributes
        )
    }
}
