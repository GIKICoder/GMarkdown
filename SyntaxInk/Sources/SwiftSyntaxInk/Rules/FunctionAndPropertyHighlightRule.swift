import Foundation
import SwiftSyntax

public struct FunctionAndPropertyHighlightRule: SwiftSyntaxHighlightRule {
    public var configuration: SwiftTheme.Configuration
    
    public init(configuration: SwiftTheme.Configuration) {
        self.configuration = configuration
    }
    
    public func attributes(for token: TokenSyntax) -> NSAttributedString? {
        // A pattern of simple function call
        if case .identifier = token.tokenKind,
           let declReferenceExprSyntax = token.parent?.as(DeclReferenceExprSyntax.self),
           declReferenceExprSyntax.baseName == token,
           let functionCallExprSyntax = declReferenceExprSyntax.parent?.as(FunctionCallExprSyntax.self),
           functionCallExprSyntax.calledExpression.id == declReferenceExprSyntax.id {
            return NSAttributedString(string: token.text, attributes: configuration.style(for: .otherFunctionAndMethodNames).attributes)
        }

        // A pattern of member access like foo.doSomething
        if case .identifier = token.tokenKind,
           let declReferenceExprSyntax = token.parent?.as(DeclReferenceExprSyntax.self),
           declReferenceExprSyntax.baseName == token,
           let memberAccessExprSyntax = declReferenceExprSyntax.parent?.as(MemberAccessExprSyntax.self),
           memberAccessExprSyntax.declName.id == declReferenceExprSyntax.id {
            return NSAttributedString(string: token.text, attributes: configuration.style(for: .otherFunctionAndMethodNames).attributes)
        }

        // macro pattern
        if token.parent?.is(MacroExpansionExprSyntax.self) ?? false {
            switch token.tokenKind {
            case .identifier, .pound:
                return NSAttributedString(string: token.text, attributes: configuration.style(for: .otherFunctionAndMethodNames).attributes)
            default: break
            }
        }

        return nil
    }
}
