import Foundation
import SyntaxInk
import SwiftSyntax

public struct SwiftTheme: Theme {
    public typealias Token = TokenSyntax
    public var configuration: Configuration
    public var highlightRules: [any SwiftSyntaxHighlightRule] = []

    public init(_ styleResolver: @escaping @Sendable (StyleKind) -> SyntaxStyle) {
        self.configuration = Configuration(styleResolver: styleResolver)
        self.highlightRules = [
            KeywordHighlightRule(configuration: configuration),
            AttributeHeuristicHighlightRule(configuration: configuration),
            StringHighlightRule(configuration: configuration),
            NumberHighlightRule(configuration: configuration),
            PreprocessorHighlightRule(configuration: configuration),
            TypeDeclarationHighlightRule(configuration: configuration),
            OtherDeclarationHighlightRule(configuration: configuration),
            ClassAndTypeNameHighlightRule(configuration: configuration),
            ClassAndTypeNameHeuristicHighlightRule(configuration: configuration),
            FunctionAndPropertyHighlightRule(configuration: configuration),
        ]
    }

    public func attributes(for token: TokenSyntax) -> NSAttributedString {
        let results = highlightRules.lazy
            .compactMap { rule in rule.attributes(for: token) }
            .first ?? NSAttributedString(string: token.text, attributes: configuration.style(for: .plainText).attributes)

        return applyTrivia(to: results, for: token)
    }


    private func applyTrivia(to attributedString: NSAttributedString, for token: TokenSyntax) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        // Add leading trivia
        for piece in token.leadingTrivia.pieces.reversed() {
            result.insert(triviaAttributedString(piece), at: 0)
        }
        
        // Add the main attributed string
        result.append(attributedString)
        
        // Add trailing trivia
        for piece in token.trailingTrivia.pieces {
            result.append(triviaAttributedString(piece))
        }
        
        return result
    }

    private func triviaAttributedString(_ trivia: TriviaPiece) -> NSAttributedString {
        switch trivia {
        case .backslashes(let count):
            return NSAttributedString(
                string: String(repeating: #"\"#, count: count),
                attributes: configuration.style(for: .plainText).attributes
            )
        case .blockComment(let string):
            return NSAttributedString(
                string: string,
                attributes: configuration.style(for: .comments).attributes
            )
        case .carriageReturns(let count):
            return NSAttributedString(
                string: String(repeating: "\r", count: count),
                attributes: configuration.style(for: .plainText).attributes
            )
        case .carriageReturnLineFeeds(let count):
            return NSAttributedString(
                string: String(repeating: "\r\n", count: count),
                attributes: configuration.style(for: .plainText).attributes
            )
        case .docBlockComment(let string):
            return NSAttributedString(
                string: string,
                attributes: configuration.style(for: .documentationMarkup).attributes
            )
        case .docLineComment(let string):
            return NSAttributedString(
                string: string,
                attributes: configuration.style(for: .documentationMarkup).attributes
            )
        case .formfeeds(let count):
            return NSAttributedString(
                string: String(repeating: "\u{c}", count: count),
                attributes: configuration.style(for: .plainText).attributes
            )
        case .lineComment(let string):
            return NSAttributedString(
                string: string,
                attributes: configuration.style(for: .comments).attributes
            )
        case .newlines(let count):
            return NSAttributedString(
                string: String(repeating: "\n", count: count),
                attributes: configuration.style(for: .plainText).attributes
            )
        case .pounds(let count):
            return NSAttributedString(string: String(repeating: "#", count: count))
        case .spaces(let count):
            return NSAttributedString(
                string: String(repeating: " ", count: count),
                attributes: configuration.style(for: .plainText).attributes
            )
        case .tabs(let count):
            return NSAttributedString(
                string: String(repeating: "\t", count: count),
                attributes: configuration.style(for: .plainText).attributes
            )
        case .unexpectedText(let string):
            return NSAttributedString(
                string: string,
                attributes: configuration.style(for: .plainText).attributes
            )
        case .verticalTabs(let count):
            return NSAttributedString(
                string: String(repeating: "\u{b}", count: count),
                attributes: configuration.style(for: .plainText).attributes
            )
        }
    }
}

extension SwiftTheme {
    // Follow Xcode's theme
    public enum StyleKind: Sendable {
        case plainText
        case keywords
        case comments
        case documentationMarkup
        case string
        case numbers
        case preprocessorStatements
        case typeDeclarations
        case otherDeclarations
        case otherClassNames
        case otherFunctionAndMethodNames
        case otherTypeNames
        case otherPropertiesAndGlobals

        // TODO: Support these types
        // case documentationMarkupKeywords
        // case marks
        // case character
        // case regexLiterals
        // case regexLiteralNumbers
        // case regexLiteralCaptureNames
        // case regexLiteralCharacterClassNames
        // case regexLiteralOperatons
        // case urls
        // case attributes
        // case projectClassNames
        // case projectFunctionAndMethodNames
        // case projectConstants
        // case projectTypeNames
        // case projectPropertiesAndGlobals
        // case projectPreprocessorMacros
        // case otherConstants
        // case otherPreprocessorMacros
        // case heading
    }

    public struct Configuration: Sendable {
        public var styleResolver: @Sendable (StyleKind) -> SyntaxStyle

        func style(for kind: StyleKind) -> SyntaxStyle {
            styleResolver(kind)
        }
    }
}
