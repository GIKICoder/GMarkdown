import Foundation

/// Go language implementation
public struct GoLanguage: Language {
    public let identifier = "go"
    public let fileExtensions = ["go"]
    private let tokenPatterns: [TokenPattern]
    
    public init() {
        var patterns: [TokenPattern] = []
        
        // Comments (highest priority)
        patterns.append(try! TokenPattern(pattern: #"//.*$"#, tokenType: .lineComment, priority: 100))
        patterns.append(try! TokenPattern(pattern: #"/\*[\s\S]*?\*/"#, tokenType: .blockComment, priority: 100))
        
        // String literals
        patterns.append(try! TokenPattern(pattern: #"`[^`]*`"#, tokenType: .stringLiteral, priority: 90))
        patterns.append(try! TokenPattern(pattern: #""(?:[^"\\]|\\.)*""#, tokenType: .stringLiteral, priority: 90))
        patterns.append(try! TokenPattern(pattern: #"'(?:[^'\\]|\\.)*'"#, tokenType: .characterLiteral, priority: 90))
        
        // Numbers
        patterns.append(try! TokenPattern(pattern: #"\b\d+\.?\d*([eE][+-]?\d+)?[fF]?\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[xX][0-9a-fA-F]+\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[oO][0-7]+\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[bB][01]+\b"#, tokenType: .numberLiteral, priority: 80))
        
        // Boolean and nil literals
        patterns.append(try! TokenPattern(pattern: #"\b(true|false)\b"#, tokenType: .booleanLiteral, priority: 75))
        patterns.append(try! TokenPattern(pattern: #"\bnil\b"#, tokenType: .nullLiteral, priority: 75))
        
        // Keywords
        let keywords = [
            "break", "case", "chan", "const", "continue", "default", "defer", "else", "fallthrough", "for", "func",
            "go", "goto", "if", "import", "interface", "map", "package", "range", "return", "select", "struct",
            "switch", "type", "var"
        ]
        let keywordPattern = "\\b(" + keywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: keywordPattern, tokenType: .keyword, priority: 70))
        
        // Control flow keywords
        let controlKeywords = ["if", "else", "for", "switch", "case", "default", "break", "continue", "return", "goto", "select", "range", "fallthrough"]
        let controlPattern = "\\b(" + controlKeywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: controlPattern, tokenType: .controlKeyword, priority: 72))
        
        // Declaration keywords
        let declKeywords = ["func", "type", "var", "const", "import", "package", "struct", "interface", "map", "chan"]
        let declPattern = "\\b(" + declKeywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: declPattern, tokenType: .declarationKeyword, priority: 72))
        
        // Built-in types
        let builtinTypes = [
            "bool", "byte", "complex64", "complex128", "error", "float32", "float64", "int", "int8", "int16", "int32",
            "int64", "rune", "string", "uint", "uint8", "uint16", "uint32", "uint64", "uintptr"
        ]
        let builtinTypePattern = "\\b(" + builtinTypes.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: builtinTypePattern, tokenType: .typeName, priority: 68))
        
        // Built-in functions
        let builtinFunctions = [
            "append", "cap", "close", "complex", "copy", "delete", "imag", "len", "make", "new", "panic", "print",
            "println", "real", "recover"
        ]
        let builtinFunctionPattern = "\\b(" + builtinFunctions.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: builtinFunctionPattern, tokenType: .builtin, priority: 68))
        
        // Function names (after func keyword)
        patterns.append(try! TokenPattern(pattern: #"\bfunc\s+(\w+)"#, tokenType: .functionName, priority: 65))
        
        // Method names (receiver functions) - simplified pattern
        patterns.append(try! TokenPattern(pattern: #"\bfunc\s+\([^)]*\)\s+(\w+)"#, tokenType: .methodName, priority: 65))
        
        // Function calls
        patterns.append(try! TokenPattern(pattern: #"\b\w+(?=\s*\()"#, tokenType: .functionName, priority: 55))
        
        // Type names (after type keyword)
        patterns.append(try! TokenPattern(pattern: #"\btype\s+(\w+)"#, tokenType: .typeName, priority: 65))
        
        // Struct names (simplified - match struct keyword)
        patterns.append(try! TokenPattern(pattern: #"\bstruct\s*\{"#, tokenType: .structName, priority: 65))
        
        // Interface names (simplified - match interface keyword)
        patterns.append(try! TokenPattern(pattern: #"\binterface\s*\{"#, tokenType: .interfaceName, priority: 65))
        
        // Package names (after package keyword)
        patterns.append(try! TokenPattern(pattern: #"\bpackage\s+(\w+)"#, tokenType: .packageName, priority: 65))
        
        // Constants (all caps)
        patterns.append(try! TokenPattern(pattern: #"\b[A-Z][A-Z0-9_]*\b"#, tokenType: .constant, priority: 50))
        
        // Channel operations
        patterns.append(try! TokenPattern(pattern: #"<-"#, tokenType: .`operator`, priority: 62))
        
        // Operators
        patterns.append(try! TokenPattern(pattern: #"[+\-*/%=<>!&|^~:.]+"#, tokenType: .`operator`, priority: 60))
        
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