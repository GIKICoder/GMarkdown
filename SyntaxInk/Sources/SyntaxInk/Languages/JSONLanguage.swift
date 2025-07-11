import Foundation

/// JSON language implementation
public struct JSONLanguage: Language {
    public let identifier = "json"
    public let fileExtensions = ["json", "jsonc", "json5"]
    private let tokenPatterns: [TokenPattern]
    
    public init() {
        var patterns: [TokenPattern] = []
        
        // Comments (for JSONC and JSON5)
        patterns.append(try! TokenPattern(pattern: #"//.*$"#, tokenType: .lineComment, priority: 100))
        patterns.append(try! TokenPattern(pattern: #"/\*[\s\S]*?\*/"#, tokenType: .blockComment, priority: 100))
        
        // String literals (JSON keys and values)
        patterns.append(try! TokenPattern(pattern: #""(?:[^"\\]|\\.)*"(?=\s*:)"#, tokenType: .jsonKey, priority: 90))
        patterns.append(try! TokenPattern(pattern: #""(?:[^"\\]|\\.)*""#, tokenType: .jsonValue, priority: 85))
        
        // Numbers
        patterns.append(try! TokenPattern(pattern: #"-?\b\d+\.?\d*([eE][+-]?\d+)?\b"#, tokenType: .numberLiteral, priority: 80))
        
        // Boolean literals
        patterns.append(try! TokenPattern(pattern: #"\b(true|false)\b"#, tokenType: .booleanLiteral, priority: 75))
        
        // Null literal
        patterns.append(try! TokenPattern(pattern: #"\bnull\b"#, tokenType: .nullLiteral, priority: 75))
        
        // Punctuation
        patterns.append(try! TokenPattern(pattern: #"[{}]"#, tokenType: .brace, priority: 40))
        patterns.append(try! TokenPattern(pattern: #"[\[\]]"#, tokenType: .bracket, priority: 40))
        patterns.append(try! TokenPattern(pattern: #","#, tokenType: .comma, priority: 40))
        patterns.append(try! TokenPattern(pattern: #":"#, tokenType: .colon, priority: 40))
        
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