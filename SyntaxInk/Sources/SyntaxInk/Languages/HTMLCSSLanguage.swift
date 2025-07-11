import Foundation

/// HTML/CSS language implementation
public struct HTMLLanguage: Language {
    public let identifier = "html"
    public let fileExtensions = ["html", "htm", "xhtml"]
    private let tokenPatterns: [TokenPattern]
    
    public init() {
        var patterns: [TokenPattern] = []
        
        // Comments (highest priority)
        patterns.append(try! TokenPattern(pattern: #"<!--[\s\S]*?-->"#, tokenType: .blockComment, priority: 100))
        
        // CDATA sections
        patterns.append(try! TokenPattern(pattern: #"<!\[CDATA\[[\s\S]*?\]\]>"#, tokenType: .stringLiteral, priority: 95))
        
        // Doctype
        patterns.append(try! TokenPattern(pattern: #"<!DOCTYPE[^>]*>"#, tokenType: .preprocessor, priority: 95))
        
        // CSS embedded in style tags (simplified)
        patterns.append(try! TokenPattern(pattern: #"<style[^>]*>([\s\S]*?)</style>"#, tokenType: .stringLiteral, priority: 90))
        
        // JavaScript embedded in script tags (simplified)
        patterns.append(try! TokenPattern(pattern: #"<script[^>]*>([\s\S]*?)</script>"#, tokenType: .stringLiteral, priority: 90))
        
        // HTML tags
        patterns.append(try! TokenPattern(pattern: #"</?[a-zA-Z][a-zA-Z0-9]*(?:\s[^>]*)?>?"#, tokenType: .htmlTag, priority: 85))
        
        // HTML attributes
        patterns.append(try! TokenPattern(pattern: #"\b[a-zA-Z-]+(?=\s*=)"#, tokenType: .htmlAttribute, priority: 80))
        
        // Attribute values (double quotes)
        patterns.append(try! TokenPattern(pattern: #"=\s*"[^"]*""#, tokenType: .htmlAttributeValue, priority: 75))
        // Attribute values (single quotes)
        patterns.append(try! TokenPattern(pattern: #"=\s*'[^']*'"#, tokenType: .htmlAttributeValue, priority: 75))
        
        // HTML entities
        patterns.append(try! TokenPattern(pattern: #"&[a-zA-Z0-9#]+;"#, tokenType: .stringLiteral, priority: 70))
        
        // Tag delimiters
        patterns.append(try! TokenPattern(pattern: #"[<>]"#, tokenType: .punctuation, priority: 60))
        
        // Operators
        patterns.append(try! TokenPattern(pattern: #"="#, tokenType: .`operator`, priority: 50))
        
        // Identifiers
        patterns.append(try! TokenPattern(pattern: #"\b[a-zA-Z_][a-zA-Z0-9_-]*\b"#, tokenType: .identifier, priority: 30))
        
        // Whitespace
        patterns.append(try! TokenPattern(pattern: #"[ \t]+"#, tokenType: .whitespace, priority: 10))
        patterns.append(try! TokenPattern(pattern: #"\n"#, tokenType: .newline, priority: 10))
        
        self.tokenPatterns = patterns
    }
    
    public func tokenize(_ code: String) -> [UniversalToken] {
        let regexLanguage = RegexLanguage(
            identifier: identifier,
            fileExtensions: fileExtensions,
            tokenPatterns: tokenPatterns
        )
        return regexLanguage.tokenize(code)
    }
}

/// CSS language implementation
public struct CSSLanguage: Language {
    public let identifier = "css"
    public let fileExtensions = ["css", "scss", "sass", "less"]
    private let tokenPatterns: [TokenPattern]
    
    public init() {
        var patterns: [TokenPattern] = []
        
        // Comments (highest priority)
        patterns.append(try! TokenPattern(pattern: #"/\*[\s\S]*?\*/"#, tokenType: .blockComment, priority: 100))
        patterns.append(try! TokenPattern(pattern: #"//.*$"#, tokenType: .lineComment, priority: 100))
        
        // Strings
        patterns.append(try! TokenPattern(pattern: #""(?:[^"\\]|\\.)*""#, tokenType: .stringLiteral, priority: 90))
        patterns.append(try! TokenPattern(pattern: #"'(?:[^'\\]|\\.)*'"#, tokenType: .stringLiteral, priority: 90))
        
        // URLs
        patterns.append(try! TokenPattern(pattern: #"url\([^)]*\)"#, tokenType: .stringLiteral, priority: 85))
        
        // At-rules
        patterns.append(try! TokenPattern(pattern: #"@[a-zA-Z-]+\b"#, tokenType: .directive, priority: 80))
        
        // Selectors
        patterns.append(try! TokenPattern(pattern: #"[.#]?[a-zA-Z][a-zA-Z0-9_-]*(?=\s*[{,])"#, tokenType: .cssSelector, priority: 75))
        patterns.append(try! TokenPattern(pattern: #"[*]"#, tokenType: .cssSelector, priority: 75))
        patterns.append(try! TokenPattern(pattern: #":[a-zA-Z-]+(?:\([^)]*\))?"#, tokenType: .cssSelector, priority: 70))
        patterns.append(try! TokenPattern(pattern: #"::[a-zA-Z-]+"#, tokenType: .cssSelector, priority: 70))
        patterns.append(try! TokenPattern(pattern: #">[+~]?"#, tokenType: .cssSelector, priority: 70))
        
        // Properties
        patterns.append(try! TokenPattern(pattern: #"[a-zA-Z-]+(?=\s*:)"#, tokenType: .cssProperty, priority: 65))
        
        // CSS Values (simplified)
        patterns.append(try! TokenPattern(pattern: #":[^;{}]*;"#, tokenType: .cssValue, priority: 60))
        
        // Numbers with units
        patterns.append(try! TokenPattern(pattern: #"\b\d+\.?\d*(px|em|rem|pt|pc|in|cm|mm|ex|ch|vw|vh|vmin|vmax|%|deg|rad|turn|s|ms|Hz|kHz|dpi|dpcm|dppx)\b"#, tokenType: .cssUnit, priority: 68))
        
        // Numbers
        patterns.append(try! TokenPattern(pattern: #"\b\d+\.?\d*\b"#, tokenType: .numberLiteral, priority: 55))
        
        // Colors
        patterns.append(try! TokenPattern(pattern: #"#[0-9a-fA-F]{3,8}\b"#, tokenType: .cssValue, priority: 63))
        patterns.append(try! TokenPattern(pattern: #"rgba?\([^)]*\)"#, tokenType: .cssValue, priority: 63))
        patterns.append(try! TokenPattern(pattern: #"hsla?\([^)]*\)"#, tokenType: .cssValue, priority: 63))
        
        // Important
        patterns.append(try! TokenPattern(pattern: #"!important\b"#, tokenType: .keyword, priority: 65))
        
        // Punctuation
        patterns.append(try! TokenPattern(pattern: #"[{}]"#, tokenType: .brace, priority: 40))
        patterns.append(try! TokenPattern(pattern: #"[\[\]]"#, tokenType: .bracket, priority: 40))
        patterns.append(try! TokenPattern(pattern: #"[()]"#, tokenType: .parenthesis, priority: 40))
        patterns.append(try! TokenPattern(pattern: #";"#, tokenType: .semicolon, priority: 40))
        patterns.append(try! TokenPattern(pattern: #","#, tokenType: .comma, priority: 40))
        patterns.append(try! TokenPattern(pattern: #":"#, tokenType: .colon, priority: 40))
        
        // Identifiers
        patterns.append(try! TokenPattern(pattern: #"\b[a-zA-Z_][a-zA-Z0-9_-]*\b"#, tokenType: .identifier, priority: 30))
        
        // Whitespace
        patterns.append(try! TokenPattern(pattern: #"[ \t]+"#, tokenType: .whitespace, priority: 10))
        patterns.append(try! TokenPattern(pattern: #"\n"#, tokenType: .newline, priority: 10))
        
        self.tokenPatterns = patterns
    }
    
    public func tokenize(_ code: String) -> [UniversalToken] {
        let regexLanguage = RegexLanguage(
            identifier: identifier,
            fileExtensions: fileExtensions,
            tokenPatterns: tokenPatterns
        )
        return regexLanguage.tokenize(code)
    }
}