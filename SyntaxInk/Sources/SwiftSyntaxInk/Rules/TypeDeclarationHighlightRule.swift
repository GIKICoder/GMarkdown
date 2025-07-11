import Foundation
import SwiftSyntax

public struct TypeDeclarationHighlightRule: SwiftSyntaxHighlightRule {
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
                    attributes: configuration.style(for: .typeDeclarations).attributes
                )
            }

            // class
            if let typeDeclarationSyntax = node.as(ClassDeclSyntax.self) {
                if typeDeclarationSyntax.name.id == token.id {
                    return .found(result())
                }
                return .notFound
            }

            // struct
            if let typeDeclarationSyntax = node.as(StructDeclSyntax.self) {
                if typeDeclarationSyntax.name.id == token.id {
                    return .found(result())
                }
                return .notFound
            }

            // protocol
            if let typeDeclarationSyntax = node.as(ProtocolDeclSyntax.self) {
                if typeDeclarationSyntax.name.id == token.id {
                    return .found(result())
                }
                return .notFound
            }

            // enum
            if let typeDeclarationSyntax = node.as(EnumDeclSyntax.self) {
                if typeDeclarationSyntax.name.id == token.id {
                    return .found(result())
                }
                return .notFound
            }

            // actor
            if let typeDeclarationSyntax = node.as(ActorDeclSyntax.self) {
                if typeDeclarationSyntax.name.id == token.id {
                    return .found(result())
                }
                return .notFound
            }

            if let extensionDeclarationSyntax = node.parent?.as(ExtensionDeclSyntax.self) {
                if extensionDeclarationSyntax.extendedType.id == node.id  {
                    return .found(result())
                }
                return .notFound
            }

            return .moveToParent
        }
    }
}
