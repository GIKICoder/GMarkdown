import Foundation
import SwiftSyntax

public struct AttributeHeuristicHighlightRule: SwiftSyntaxHighlightRule {
    public var configuration: SwiftTheme.Configuration
    var predefinedAttributes: [String] {
        // Follow the official document
        // https://docs.swift.org/swift-book/documentation/the-swift-programming-language/attributes/
        [
            "available",
            "backDeployed",
            "discardableResult",
            "dynamicCallable",
            "dynamicMemberLookup",
            "frozen",
            "GKInspectable",
            "inlinable",
            "main",
            "nonobjc",
            "NSApplicationMain",
            "NSCopying",
            "NSManaged",
            "objc",
            "objcMembers",
            "preconcurrency",
            "propertyWrapper",
            "resultBuilder",
            "requires_stored_property_inits",
            "testable",
            "UIApplicationMain",
            "unchecked",
            "usableFromInline",
            "warn_unqualified_access",
            "IBAction",
            "IBSegueAction",
            "IBOutlet",
            "IBDesignable",
            "IBInspectable",
            "autoclosure",
            "convention",
            "escaping",
            "Sendable",
            "unknown"
        ]
    }
    public init(configuration: SwiftTheme.Configuration) {
        self.configuration = configuration
    }
    
    public func attributes(for token: TokenSyntax) -> NSAttributedString? {
        let attributeName: String
        if let identifierTypeSyntax = token.parent?.as(IdentifierTypeSyntax.self),
           identifierTypeSyntax.parent?.is(AttributeSyntax.self) ?? false {
            attributeName = token.text
        } else if token.tokenKind == .atSign,
                  let attribute = token.parent?.as(AttributeSyntax.self),
                  let identifierTypeSyntax = attribute.attributeName.as(IdentifierTypeSyntax.self) {
            attributeName = identifierTypeSyntax.name.text
        } else {
            return nil
        }


        return predefinedAttributes.contains(attributeName)
        ? NSAttributedString(string: token.text, attributes: configuration.style(for: .keywords).attributes)
        : NSAttributedString(string: token.text, attributes: configuration.style(for: .otherTypeNames).attributes)
    }
}
