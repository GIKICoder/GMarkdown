import Foundation

/// JavaScript/TypeScript language implementation
public struct JavaScriptLanguage: Language {
    public let identifier: String
    public let fileExtensions: [String]
    private let tokenPatterns: [TokenPattern]
    
    public init(includeTypeScript: Bool = true) {
        self.identifier = includeTypeScript ? "javascript-typescript" : "javascript"
        self.fileExtensions = includeTypeScript ? ["js", "jsx", "ts", "tsx", "mjs", "cjs"] : ["js", "jsx", "mjs", "cjs"]
        
        var patterns: [TokenPattern] = []
        
        // Comments (highest priority)
        patterns.append(try! TokenPattern(pattern: #"//.*$"#, tokenType: .lineComment, priority: 100))
        patterns.append(try! TokenPattern(pattern: #"/\*[\s\S]*?\*/"#, tokenType: .blockComment, priority: 100))
        patterns.append(try! TokenPattern(pattern: #"(?:///?|/\*\*?).*?(?:\*/|$)"#, tokenType: .docComment, priority: 100))
        
        // String literals
        patterns.append(try! TokenPattern(pattern: #""(?:[^"\\]|\\.)*""#, tokenType: .stringLiteral, priority: 90))
        patterns.append(try! TokenPattern(pattern: #"'(?:[^'\\]|\\.)*'"#, tokenType: .stringLiteral, priority: 90))
        patterns.append(try! TokenPattern(pattern: #"`(?:[^`\\]|\\.)*`"#, tokenType: .stringLiteral, priority: 90))
        
        // Regular expressions
        patterns.append(try! TokenPattern(pattern: #"/(?![/*])(?:[^/\\\n]|\\.)+/[gimuy]*"#, tokenType: .regexLiteral, priority: 85))
        
        // Numbers
        patterns.append(try! TokenPattern(pattern: #"\b\d+\.?\d*([eE][+-]?\d+)?\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[xX][0-9a-fA-F]+\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[oO][0-7]+\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[bB][01]+\b"#, tokenType: .numberLiteral, priority: 80))
        
        // Boolean and null literals
        patterns.append(try! TokenPattern(pattern: #"\b(true|false)\b"#, tokenType: .booleanLiteral, priority: 75))
        patterns.append(try! TokenPattern(pattern: #"\b(null|undefined)\b"#, tokenType: .nullLiteral, priority: 75))
        
        // Keywords
        let jsKeywords = [
            "abstract", "arguments", "await", "boolean", "break", "byte", "case", "catch", "char", "class", "const", "continue",
            "debugger", "default", "delete", "do", "double", "else", "enum", "eval", "export", "extends", "false", "final",
            "finally", "float", "for", "function", "goto", "if", "implements", "import", "in", "instanceof", "int", "interface",
            "let", "long", "native", "new", "null", "package", "private", "protected", "public", "return", "short", "static",
            "super", "switch", "synchronized", "this", "throw", "throws", "transient", "true", "try", "typeof", "var", "void",
            "volatile", "while", "with", "yield"
        ]
        
        let tsKeywords = [
            "as", "any", "declare", "keyof", "module", "namespace", "never", "readonly", "string", "symbol", "type", "unique",
            "unknown", "asserts", "is", "infer", "out", "satisfies", "using", "from"
        ]
        
        let allKeywords = includeTypeScript ? jsKeywords + tsKeywords : jsKeywords
        let keywordPattern = "\\b(" + allKeywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: keywordPattern, tokenType: .keyword, priority: 70))
        
        // Control flow keywords
        let controlKeywords = ["if", "else", "for", "while", "do", "switch", "case", "default", "break", "continue", "return", "try", "catch", "finally", "throw"]
        let controlPattern = "\\b(" + controlKeywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: controlPattern, tokenType: .controlKeyword, priority: 72))
        
        // Declaration keywords
        let declKeywords = ["function", "var", "let", "const", "class", "interface", "type", "enum", "import", "export", "declare", "module", "namespace"]
        let declPattern = "\\b(" + declKeywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: declPattern, tokenType: .declarationKeyword, priority: 72))
        
        // Operators
        patterns.append(try! TokenPattern(pattern: #"[+\-*/%=<>!&|^~?:.]+"#, tokenType: .`operator`, priority: 60))
        
        // Function names (after function keyword and function calls)
        patterns.append(try! TokenPattern(pattern: #"\bfunction\s+(\w+)"#, tokenType: .functionName, priority: 65))
        patterns.append(try! TokenPattern(pattern: #"\b\w+(?=\s*\()"#, tokenType: .functionName, priority: 55))
        
        // Class names (after class keyword)
        patterns.append(try! TokenPattern(pattern: #"\bclass\s+(\w+)"#, tokenType: .className, priority: 65))
        
        // TypeScript specific
        if includeTypeScript {
            patterns.append(try! TokenPattern(pattern: #"\binterface\s+(\w+)"#, tokenType: .interfaceName, priority: 65))
            patterns.append(try! TokenPattern(pattern: #"\btype\s+(\w+)"#, tokenType: .typeName, priority: 65))
            patterns.append(try! TokenPattern(pattern: #"\benum\s+(\w+)"#, tokenType: .enumName, priority: 65))
            patterns.append(try! TokenPattern(pattern: #":\s*\w+"#, tokenType: .typeName, priority: 50))
            patterns.append(try! TokenPattern(pattern: #"<[^>]+>"#, tokenType: .generic, priority: 50))
        }
        
        // Identifiers
        patterns.append(try! TokenPattern(pattern: #"\b[a-zA-Z_$][a-zA-Z0-9_$]*\b"#, tokenType: .identifier, priority: 30))
        
        // Punctuation
        patterns.append(try! TokenPattern(pattern: #"[{}]"#, tokenType: .brace, priority: 40))
        patterns.append(try! TokenPattern(pattern: #"[\[\]]"#, tokenType: .bracket, priority: 40))
        patterns.append(try! TokenPattern(pattern: #"[()]"#, tokenType: .parenthesis, priority: 40))
        patterns.append(try! TokenPattern(pattern: #";"#, tokenType: .semicolon, priority: 40))
        patterns.append(try! TokenPattern(pattern: #","#, tokenType: .comma, priority: 40))
        patterns.append(try! TokenPattern(pattern: #"\."#, tokenType: .dot, priority: 40))
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