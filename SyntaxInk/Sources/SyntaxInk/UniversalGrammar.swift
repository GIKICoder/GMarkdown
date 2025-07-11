import Foundation

/// A universal grammar that works with any language
public struct UniversalGrammar: Grammar {
    public typealias Token = UniversalToken
    
    private let language: Language
    
    public init(language: Language) {
        self.language = language
    }
    
    public func tokenize(_ code: String) -> [UniversalToken] {
        return language.tokenize(code)
    }
}

/// A universal theme protocol for multi-language syntax highlighting
public protocol UniversalTheme: Theme where Token == UniversalToken {
    /// Unique identifier for this theme
    var identifier: String { get }
    
    /// Get style for a specific token type
    func style(for tokenType: TokenType) -> SyntaxStyle
    
    /// Get style for a specific token (allows for more complex logic)
    func style(for token: UniversalToken) -> SyntaxStyle
}

/// Default implementation of UniversalTheme
extension UniversalTheme {
    public func style(for token: UniversalToken) -> SyntaxStyle {
        return style(for: token.type)
    }
    
    public func attributes(for token: UniversalToken) -> NSAttributedString {
        let style = self.style(for: token)
        return NSAttributedString(string: token.text, attributes: style.attributes)
    }
}

/// A concrete implementation of UniversalTheme
public struct StandardUniversalTheme: UniversalTheme {
    public typealias Token = UniversalToken
    
    private let styleMap: [TokenType: SyntaxStyle]
    public let identifier: String
    
    public init(styleMap: [TokenType: SyntaxStyle], identifier: String = UUID().uuidString) {
        self.styleMap = styleMap
        self.identifier = identifier
    }
    
    public func style(for tokenType: TokenType) -> SyntaxStyle {
        return styleMap[tokenType] ?? defaultStyle
    }
    
    private var defaultStyle: SyntaxStyle {
        SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0, green: 0, blue: 0)
        )
    }
}

/// Universal syntax highlighter type alias
public typealias UniversalSyntaxHighlighter = SyntaxHighlighter<UniversalGrammar, StandardUniversalTheme>