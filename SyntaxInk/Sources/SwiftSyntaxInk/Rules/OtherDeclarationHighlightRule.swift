import Foundation
import SwiftSyntax

public struct OtherDeclarationHighlightRule: SwiftSyntaxHighlightRule {
    public var configuration: SwiftTheme.Configuration

    public init(configuration: SwiftTheme.Configuration) {
        self.configuration = configuration
    }

    public func attributes(for token: TokenSyntax) -> NSAttributedString? {
        guard case .identifier = token.tokenKind else {
            return nil
        }

        return walkParent(of: Syntax(token)) { node in
            func result() -> NSAttributedString {
                NSAttributedString(
                    string: token.text,
                    attributes: configuration.style(for: .otherDeclarations).attributes
                )
            }

            // property declaration
            if let patternBinding = node.parent?.as(PatternBindingSyntax.self),
               patternBinding.pattern.id == node.id {
                if let patternBindingList = patternBinding.parent?.as(PatternBindingListSyntax.self),
                   let variableDeclaration = patternBindingList.parent?.as(VariableDeclSyntax.self),
                   variableDeclaration.parent?.is(MemberBlockItemSyntax.self) ?? false {
                    return .found(result())
                }
                return .notFound
            }

            // function declaration
            if let functionDeclaration = node.as(FunctionDeclSyntax.self) {
                if functionDeclaration.name.id == token.id {
                    return .found(result())
                }
                return .notFound
            }

            // argument label of a function
            if let functionParameter = node.as(FunctionParameterSyntax.self) {
                if functionParameter.firstName.id == token.id {
                    return .found(result())
                }
                return .notFound
            }

            // typealias declaration
            if let typeAlias = node.as(TypeAliasDeclSyntax.self) {
                if typeAlias.name.id == token.id {
                    return .found(result())
                }
                return .notFound
            }

            if let associatedType = node.as(AssociatedTypeDeclSyntax.self) {
                if associatedType.name.id == token.id {
                    return .found(result())
                }
                return .notFound
            }
            return .moveToParent
        }
    }
}
