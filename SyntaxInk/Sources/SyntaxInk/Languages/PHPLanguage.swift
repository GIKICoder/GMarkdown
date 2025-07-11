import Foundation

/// PHP language implementation
public struct PHPLanguage: Language {
    public let identifier = "php"
    public let fileExtensions = ["php", "php3", "php4", "php5", "phtml"]
    private let tokenPatterns: [TokenPattern]
    
    public init() {
        var patterns: [TokenPattern] = []
        
        // PHP opening/closing tags
        patterns.append(try! TokenPattern(pattern: #"<\?php\b"#, tokenType: .preprocessor, priority: 100))
        patterns.append(try! TokenPattern(pattern: #"<\?"#, tokenType: .preprocessor, priority: 100))
        patterns.append(try! TokenPattern(pattern: #"\?>"#, tokenType: .preprocessor, priority: 100))
        
        // Comments (highest priority)
        patterns.append(try! TokenPattern(pattern: #"//.*$"#, tokenType: .lineComment, priority: 100))
        patterns.append(try! TokenPattern(pattern: #"#.*$"#, tokenType: .lineComment, priority: 100))
        patterns.append(try! TokenPattern(pattern: #"/\*[\s\S]*?\*/"#, tokenType: .blockComment, priority: 100))
        
        // String literals
        patterns.append(try! TokenPattern(pattern: #""(?:[^"\\]|\\.)*""#, tokenType: .stringLiteral, priority: 90))
        patterns.append(try! TokenPattern(pattern: #"'(?:[^'\\]|\\.)*'"#, tokenType: .stringLiteral, priority: 90))
        patterns.append(try! TokenPattern(pattern: #"<<<['\"]?(\w+)['\"]?[\s\S]*?\n\1"#, tokenType: .stringLiteral, priority: 95))
        
        // Numbers
        patterns.append(try! TokenPattern(pattern: #"\b\d+\.?\d*([eE][+-]?\d+)?\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[xX][0-9a-fA-F]+\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[oO][0-7]+\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[bB][01]+\b"#, tokenType: .numberLiteral, priority: 80))
        
        // Boolean and null literals
        patterns.append(try! TokenPattern(pattern: #"\b(true|false|TRUE|FALSE)\b"#, tokenType: .booleanLiteral, priority: 75))
        patterns.append(try! TokenPattern(pattern: #"\b(null|NULL)\b"#, tokenType: .nullLiteral, priority: 75))
        
        // Keywords
        let keywords = [
            "abstract", "and", "array", "as", "break", "callable", "case", "catch", "class", "clone", "const",
            "continue", "declare", "default", "die", "do", "echo", "else", "elseif", "empty", "enddeclare",
            "endfor", "endforeach", "endif", "endswitch", "endwhile", "eval", "exit", "extends", "final",
            "finally", "for", "foreach", "function", "global", "goto", "if", "implements", "include",
            "include_once", "instanceof", "insteadof", "interface", "isset", "list", "namespace", "new",
            "or", "print", "private", "protected", "public", "require", "require_once", "return", "static",
            "switch", "throw", "trait", "try", "unset", "use", "var", "while", "xor", "yield", "yield from"
        ]
        let keywordPattern = "\\b(" + keywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: keywordPattern, tokenType: .keyword, priority: 70))
        
        // Control flow keywords
        let controlKeywords = ["if", "else", "elseif", "endif", "for", "endfor", "foreach", "endforeach", "while", "endwhile", "do", "switch", "endswitch", "case", "default", "break", "continue", "return", "goto", "try", "catch", "finally", "throw"]
        let controlPattern = "\\b(" + controlKeywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: controlPattern, tokenType: .controlKeyword, priority: 72))
        
        // Declaration keywords
        let declKeywords = ["class", "interface", "trait", "function", "namespace", "use", "const", "var", "declare"]
        let declPattern = "\\b(" + declKeywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: declPattern, tokenType: .declarationKeyword, priority: 72))
        
        // Visibility modifiers
        let modifiers = ["public", "private", "protected", "static", "final", "abstract"]
        let modifierPattern = "\\b(" + modifiers.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: modifierPattern, tokenType: .modifier, priority: 68))
        
        // Variables
        patterns.append(try! TokenPattern(pattern: #"\$[a-zA-Z_][a-zA-Z0-9_]*\b"#, tokenType: .variableName, priority: 65))
        
        // Constants
        patterns.append(try! TokenPattern(pattern: #"\b[A-Z][A-Z0-9_]*\b"#, tokenType: .constant, priority: 50))
        
        // Function names (after function keyword)
        patterns.append(try! TokenPattern(pattern: #"\bfunction\s+(\w+)"#, tokenType: .functionName, priority: 65))
        
        // Class names (after class keyword)
        patterns.append(try! TokenPattern(pattern: #"\bclass\s+(\w+)"#, tokenType: .className, priority: 65))
        
        // Interface names (after interface keyword)
        patterns.append(try! TokenPattern(pattern: #"\binterface\s+(\w+)"#, tokenType: .interfaceName, priority: 65))
        
        // Trait names (after trait keyword)
        patterns.append(try! TokenPattern(pattern: #"\btrait\s+(\w+)"#, tokenType: .protocolName, priority: 65))
        
        // Function calls
        patterns.append(try! TokenPattern(pattern: #"\b\w+(?=\s*\()"#, tokenType: .functionName, priority: 55))
        
        // Namespace separator
        patterns.append(try! TokenPattern(pattern: #"\\"#, tokenType: .`operator`, priority: 62))
        
        // Object operators
        patterns.append(try! TokenPattern(pattern: #"->"#, tokenType: .`operator`, priority: 62))
        patterns.append(try! TokenPattern(pattern: #"::"#, tokenType: .`operator`, priority: 62))
        
        // Operators
        patterns.append(try! TokenPattern(pattern: #"[+\-*/%=<>!&|^~?:.]+"#, tokenType: .`operator`, priority: 60))
        
        // Identifiers
        patterns.append(try! TokenPattern(pattern: #"\b[a-zA-Z_][a-zA-Z0-9_]*\b"#, tokenType: .identifier, priority: 30))
        
        // Punctuation
        patterns.append(try! TokenPattern(pattern: #"[{}]"#, tokenType: .brace, priority: 40))
        patterns.append(try! TokenPattern(pattern: #"[\[\]]"#, tokenType: .bracket, priority: 40))
        patterns.append(try! TokenPattern(pattern: #"[()]"#, tokenType: .parenthesis, priority: 40))
        patterns.append(try! TokenPattern(pattern: #";"#, tokenType: .semicolon, priority: 40))
        patterns.append(try! TokenPattern(pattern: #","#, tokenType: .comma, priority: 40))
        
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