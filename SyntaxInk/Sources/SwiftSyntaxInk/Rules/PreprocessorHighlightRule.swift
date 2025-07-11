import Foundation
import SwiftSyntax

public struct PreprocessorHighlightRule: SwiftSyntaxHighlightRule {
    public var configuration: SwiftTheme.Configuration

    public init(configuration: SwiftTheme.Configuration) {
        self.configuration = configuration
    }

    public func attributes(for token: TokenSyntax) -> NSAttributedString? {
        if [TokenKind.poundIf, .poundEndif, .poundElse, .poundElseif].contains(token.tokenKind) {
            return NSAttributedString(
                string: token.text,
                attributes: configuration.style(for: .preprocessorStatements).attributes
            )
        }

        return walkParent(of: Syntax(token)) { node in
            guard let ifConfigClauseSyntax = node.parent?.as(IfConfigClauseSyntax.self) else {
                return .moveToParent
            }
            if ifConfigClauseSyntax.condition?.id == node.id {
                let result = NSAttributedString(
                    string: token.text,
                    attributes: configuration.style(for: .preprocessorStatements).attributes
                )
                return .found(result)
            }
            return .notFound
        }
    }
}
