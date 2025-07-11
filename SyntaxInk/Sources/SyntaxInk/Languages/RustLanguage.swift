import Foundation

/// Rust language implementation
public struct RustLanguage: Language {
    public let identifier = "rust"
    public let fileExtensions = ["rs"]
    private let tokenPatterns: [TokenPattern]
    
    public init() {
        var patterns: [TokenPattern] = []
        
        // Comments (highest priority)
        patterns.append(try! TokenPattern(pattern: #"//.*$"#, tokenType: .lineComment, priority: 100))
        patterns.append(try! TokenPattern(pattern: #"/\*[\s\S]*?\*/"#, tokenType: .blockComment, priority: 100))
        patterns.append(try! TokenPattern(pattern: #"///.*$"#, tokenType: .docComment, priority: 100))
        patterns.append(try! TokenPattern(pattern: #"//!.*$"#, tokenType: .docComment, priority: 100))
        
        // String literals
        patterns.append(try! TokenPattern(pattern: #"r"[^"]*""#, tokenType: .stringLiteral, priority: 90))
        patterns.append(try! TokenPattern(pattern: #""(?:[^"\\]|\\.)*""#, tokenType: .stringLiteral, priority: 90))
        patterns.append(try! TokenPattern(pattern: #"'(?:[^'\\]|\\.)*'"#, tokenType: .characterLiteral, priority: 90))
        
        // Numbers
        patterns.append(try! TokenPattern(pattern: #"\b\d+\.?\d*([eE][+-]?\d+)?[fF]?(32|64)?\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[xX][0-9a-fA-F]+[uUiI]?(8|16|32|64|128|size)?\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[oO][0-7]+[uUiI]?(8|16|32|64|128|size)?\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[bB][01]+[uUiI]?(8|16|32|64|128|size)?\b"#, tokenType: .numberLiteral, priority: 80))
        
        // Boolean and special literals
        patterns.append(try! TokenPattern(pattern: #"\b(true|false)\b"#, tokenType: .booleanLiteral, priority: 75))
        patterns.append(try! TokenPattern(pattern: #"\bNone\b"#, tokenType: .nullLiteral, priority: 75))
        patterns.append(try! TokenPattern(pattern: #"\bSome\b"#, tokenType: .keyword, priority: 75))
        
        // Keywords
        let keywords = [
            "as", "async", "await", "break", "const", "continue", "crate", "dyn", "else", "enum", "extern", "false",
            "fn", "for", "if", "impl", "in", "let", "loop", "match", "mod", "move", "mut", "pub", "ref", "return",
            "self", "Self", "static", "struct", "super", "trait", "true", "type", "union", "unsafe", "use", "where",
            "while", "yield", "abstract", "become", "box", "do", "final", "macro", "override", "priv", "typeof",
            "unsized", "virtual", "try"
        ]
        let keywordPattern = "\\b(" + keywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: keywordPattern, tokenType: .keyword, priority: 70))
        
        // Control flow keywords
        let controlKeywords = ["if", "else", "match", "for", "while", "loop", "break", "continue", "return", "yield"]
        let controlPattern = "\\b(" + controlKeywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: controlPattern, tokenType: .controlKeyword, priority: 72))
        
        // Declaration keywords
        let declKeywords = ["fn", "struct", "enum", "trait", "impl", "type", "mod", "use", "const", "static", "let", "extern", "crate"]
        let declPattern = "\\b(" + declKeywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: declPattern, tokenType: .declarationKeyword, priority: 72))
        
        // Visibility and mutability
        let modifiers = ["pub", "mut", "ref", "unsafe", "async", "const", "static", "extern"]
        let modifierPattern = "\\b(" + modifiers.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: modifierPattern, tokenType: .modifier, priority: 68))
        
        // Built-in types
        let builtinTypes = [
            "bool", "char", "str", "i8", "i16", "i32", "i64", "i128", "isize", "u8", "u16", "u32", "u64", "u128",
            "usize", "f32", "f64", "Box", "Vec", "HashMap", "Option", "Result", "String"
        ]
        let builtinTypePattern = "\\b(" + builtinTypes.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: builtinTypePattern, tokenType: .typeName, priority: 68))
        
        // Attributes
        patterns.append(try! TokenPattern(pattern: #"#\[[^\]]*\]"#, tokenType: .attribute, priority: 65))
        
        // Macros
        patterns.append(try! TokenPattern(pattern: #"\b\w+!"#, tokenType: .macro, priority: 65))
        
        // Function names (after fn keyword)
        patterns.append(try! TokenPattern(pattern: #"\bfn\s+(\w+)"#, tokenType: .functionName, priority: 65))
        
        // Struct names (after struct keyword)
        patterns.append(try! TokenPattern(pattern: #"\bstruct\s+(\w+)"#, tokenType: .structName, priority: 65))
        
        // Enum names (after enum keyword)
        patterns.append(try! TokenPattern(pattern: #"\benum\s+(\w+)"#, tokenType: .enumName, priority: 65))
        
        // Trait names (after trait keyword)
        patterns.append(try! TokenPattern(pattern: #"\btrait\s+(\w+)"#, tokenType: .protocolName, priority: 65))
        
        // Type names (after type keyword)
        patterns.append(try! TokenPattern(pattern: #"\btype\s+(\w+)"#, tokenType: .typeName, priority: 65))
        
        // Module names (after mod keyword)
        patterns.append(try! TokenPattern(pattern: #"\bmod\s+(\w+)"#, tokenType: .moduleName, priority: 65))
        
        // Function calls
        patterns.append(try! TokenPattern(pattern: #"\b\w+(?=\s*\()"#, tokenType: .functionName, priority: 55))
        
        // Constants (all caps)
        patterns.append(try! TokenPattern(pattern: #"\b[A-Z][A-Z0-9_]*\b"#, tokenType: .constant, priority: 50))
        
        // Lifetimes
        patterns.append(try! TokenPattern(pattern: #"'[a-zA-Z_][a-zA-Z0-9_]*\b"#, tokenType: .label, priority: 60))
        
        // Operators
        patterns.append(try! TokenPattern(pattern: #"[+\-*/%=<>!&|^~?:.]+"#, tokenType: .`operator`, priority: 60))
        patterns.append(try! TokenPattern(pattern: #"->"#, tokenType: .`operator`, priority: 62))
        patterns.append(try! TokenPattern(pattern: #"=>"#, tokenType: .`operator`, priority: 62))
        patterns.append(try! TokenPattern(pattern: #"::"#, tokenType: .`operator`, priority: 62))
        
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