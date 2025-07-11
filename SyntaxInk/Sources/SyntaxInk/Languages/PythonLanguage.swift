import Foundation

/// Python language implementation
public struct PythonLanguage: Language {
    public let identifier = "python"
    public let fileExtensions = ["py", "pyw", "pyi"]
    private let tokenPatterns: [TokenPattern]
    
    public init() {
        var patterns: [TokenPattern] = []
        
        // Comments (highest priority)
        patterns.append(try! TokenPattern(pattern: #"#.*$"#, tokenType: .lineComment, priority: 100))
        patterns.append(try! TokenPattern(pattern: #"(?:"""[\s\S]*?"""|'''[\s\S]*?''')"#, tokenType: .docComment, priority: 100))
        
        // String literals
        patterns.append(try! TokenPattern(pattern: #"[bBfFrRuU]*"""[\s\S]*?""""#, tokenType: .stringLiteral, priority: 90))
        patterns.append(try! TokenPattern(pattern: #"[bBfFrRuU]*'''[\s\S]*?'''"#, tokenType: .stringLiteral, priority: 90))
        patterns.append(try! TokenPattern(pattern: #"[bBfFrRuU]*"(?:[^"\\]|\\.)*""#, tokenType: .stringLiteral, priority: 90))
        patterns.append(try! TokenPattern(pattern: #"[bBfFrRuU]*'(?:[^'\\]|\\.)*'"#, tokenType: .stringLiteral, priority: 90))
        
        // Numbers
        patterns.append(try! TokenPattern(pattern: #"\b\d+\.?\d*([eE][+-]?\d+)?[jJ]?\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[xX][0-9a-fA-F]+\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[oO][0-7]+\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[bB][01]+\b"#, tokenType: .numberLiteral, priority: 80))
        
        // Boolean and None literals
        patterns.append(try! TokenPattern(pattern: #"\b(True|False)\b"#, tokenType: .booleanLiteral, priority: 75))
        patterns.append(try! TokenPattern(pattern: #"\bNone\b"#, tokenType: .nullLiteral, priority: 75))
        
        // Keywords
        let keywords = [
            "and", "as", "assert", "async", "await", "break", "class", "continue", "def", "del", "elif", "else", "except",
            "finally", "for", "from", "global", "if", "import", "in", "is", "lambda", "nonlocal", "not", "or", "pass",
            "raise", "return", "try", "while", "with", "yield", "match", "case", "type"
        ]
        let keywordPattern = "\\b(" + keywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: keywordPattern, tokenType: .keyword, priority: 70))
        
        // Control flow keywords
        let controlKeywords = ["if", "elif", "else", "for", "while", "break", "continue", "return", "try", "except", "finally", "raise", "match", "case"]
        let controlPattern = "\\b(" + controlKeywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: controlPattern, tokenType: .controlKeyword, priority: 72))
        
        // Declaration keywords
        let declKeywords = ["def", "class", "import", "from", "global", "nonlocal", "lambda", "async", "type"]
        let declPattern = "\\b(" + declKeywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: declPattern, tokenType: .declarationKeyword, priority: 72))
        
        // Built-in functions
        let builtins = [
            "abs", "all", "any", "ascii", "bin", "bool", "breakpoint", "bytearray", "bytes", "callable", "chr", "classmethod",
            "compile", "complex", "delattr", "dict", "dir", "divmod", "enumerate", "eval", "exec", "filter", "float",
            "format", "frozenset", "getattr", "globals", "hasattr", "hash", "help", "hex", "id", "input", "int", "isinstance",
            "issubclass", "iter", "len", "list", "locals", "map", "max", "memoryview", "min", "next", "object", "oct",
            "open", "ord", "pow", "print", "property", "range", "repr", "reversed", "round", "set", "setattr", "slice",
            "sorted", "staticmethod", "str", "sum", "super", "tuple", "type", "vars", "zip"
        ]
        let builtinPattern = "\\b(" + builtins.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: builtinPattern, tokenType: .builtin, priority: 68))
        
        // Decorators
        patterns.append(try! TokenPattern(pattern: #"@\w+"#, tokenType: .decorator, priority: 65))
        
        // Function names (after def keyword)
        patterns.append(try! TokenPattern(pattern: #"\bdef\s+(\w+)"#, tokenType: .functionName, priority: 65))
        
        // Class names (after class keyword)
        patterns.append(try! TokenPattern(pattern: #"\bclass\s+(\w+)"#, tokenType: .className, priority: 65))
        
        // Method calls
        patterns.append(try! TokenPattern(pattern: #"\b\w+(?=\s*\()"#, tokenType: .functionName, priority: 55))
        
        // Operators
        patterns.append(try! TokenPattern(pattern: #"[+\-*/%=<>!&|^~]+"#, tokenType: .`operator`, priority: 60))
        patterns.append(try! TokenPattern(pattern: #"\*\*"#, tokenType: .`operator`, priority: 62))
        patterns.append(try! TokenPattern(pattern: #"//"#, tokenType: .`operator`, priority: 62))
        patterns.append(try! TokenPattern(pattern: #"[<>]=?"#, tokenType: .`operator`, priority: 62))
        patterns.append(try! TokenPattern(pattern: #"[!=]="#, tokenType: .`operator`, priority: 62))
        
        // Identifiers
        patterns.append(try! TokenPattern(pattern: #"\b[a-zA-Z_][a-zA-Z0-9_]*\b"#, tokenType: .identifier, priority: 30))
        
        // Special variables
        patterns.append(try! TokenPattern(pattern: #"\b__\w+__\b"#, tokenType: .constant, priority: 50))
        patterns.append(try! TokenPattern(pattern: #"\bself\b"#, tokenType: .keyword, priority: 50))
        patterns.append(try! TokenPattern(pattern: #"\bcls\b"#, tokenType: .keyword, priority: 50))
        
        // Punctuation
        patterns.append(try! TokenPattern(pattern: #"[{}]"#, tokenType: .brace, priority: 40))
        patterns.append(try! TokenPattern(pattern: #"[\[\]]"#, tokenType: .bracket, priority: 40))
        patterns.append(try! TokenPattern(pattern: #"[()]"#, tokenType: .parenthesis, priority: 40))
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