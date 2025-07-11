import Foundation

/// Java language implementation
public struct JavaLanguage: Language {
    public let identifier = "java"
    public let fileExtensions = ["java"]
    private let tokenPatterns: [TokenPattern]
    
    public init() {
        var patterns: [TokenPattern] = []
        
        // Comments (highest priority)
        patterns.append(try! TokenPattern(pattern: #"//.*$"#, tokenType: .lineComment, priority: 100))
        patterns.append(try! TokenPattern(pattern: #"/\*[\s\S]*?\*/"#, tokenType: .blockComment, priority: 100))
        patterns.append(try! TokenPattern(pattern: #"/\*\*[\s\S]*?\*/"#, tokenType: .docComment, priority: 100))
        
        // String literals
        patterns.append(try! TokenPattern(pattern: #""(?:[^"\\]|\\.)*""#, tokenType: .stringLiteral, priority: 90))
        patterns.append(try! TokenPattern(pattern: #"'(?:[^'\\]|\\.)*'"#, tokenType: .characterLiteral, priority: 90))
        
        // Numbers
        patterns.append(try! TokenPattern(pattern: #"\b\d+\.?\d*([eE][+-]?\d+)?[fFdDlL]?\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[xX][0-9a-fA-F]+[lL]?\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[bB][01]+[lL]?\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[0-7]+[lL]?\b"#, tokenType: .numberLiteral, priority: 80))
        
        // Boolean and null literals
        patterns.append(try! TokenPattern(pattern: #"\b(true|false)\b"#, tokenType: .booleanLiteral, priority: 75))
        patterns.append(try! TokenPattern(pattern: #"\bnull\b"#, tokenType: .nullLiteral, priority: 75))
        
        // Keywords
        let keywords = [
            "abstract", "assert", "boolean", "break", "byte", "case", "catch", "char", "class", "const", "continue",
            "default", "do", "double", "else", "enum", "extends", "final", "finally", "float", "for", "goto", "if",
            "implements", "import", "instanceof", "int", "interface", "long", "native", "new", "package", "private",
            "protected", "public", "return", "short", "static", "strictfp", "super", "switch", "synchronized", "this",
            "throw", "throws", "transient", "try", "void", "volatile", "while"
        ]
        let keywordPattern = "\\b(" + keywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: keywordPattern, tokenType: .keyword, priority: 70))
        
        // Control flow keywords
        let controlKeywords = ["if", "else", "for", "while", "do", "switch", "case", "default", "break", "continue", "return", "try", "catch", "finally", "throw"]
        let controlPattern = "\\b(" + controlKeywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: controlPattern, tokenType: .controlKeyword, priority: 72))
        
        // Declaration keywords
        let declKeywords = ["class", "interface", "enum", "import", "package", "extends", "implements"]
        let declPattern = "\\b(" + declKeywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: declPattern, tokenType: .declarationKeyword, priority: 72))
        
        // Modifiers
        let modifiers = ["public", "private", "protected", "static", "final", "abstract", "synchronized", "volatile", "transient", "native", "strictfp"]
        let modifierPattern = "\\b(" + modifiers.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: modifierPattern, tokenType: .modifier, priority: 68))
        
        // Primitive types
        let primitiveTypes = ["boolean", "byte", "char", "double", "float", "int", "long", "short", "void"]
        let primitivePattern = "\\b(" + primitiveTypes.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: primitivePattern, tokenType: .typeName, priority: 68))
        
        // Annotations
        patterns.append(try! TokenPattern(pattern: #"@\w+"#, tokenType: .annotation, priority: 65))
        
        // Class names (after class keyword)
        patterns.append(try! TokenPattern(pattern: #"\bclass\s+(\w+)"#, tokenType: .className, priority: 65))
        
        // Interface names (after interface keyword)
        patterns.append(try! TokenPattern(pattern: #"\binterface\s+(\w+)"#, tokenType: .interfaceName, priority: 65))
        
        // Enum names (after enum keyword)
        patterns.append(try! TokenPattern(pattern: #"\benum\s+(\w+)"#, tokenType: .enumName, priority: 65))
        
        // Method names
        patterns.append(try! TokenPattern(pattern: #"\b\w+(?=\s*\()"#, tokenType: .methodName, priority: 55))
        
        // Generics
        patterns.append(try! TokenPattern(pattern: #"<[^>]+>"#, tokenType: .generic, priority: 50))
        
        // Constants (all caps)
        patterns.append(try! TokenPattern(pattern: #"\b[A-Z][A-Z0-9_]*\b"#, tokenType: .constant, priority: 50))
        
        // Operators
        patterns.append(try! TokenPattern(pattern: #"[+\-*/%=<>!&|^~?:]+"#, tokenType: .`operator`, priority: 60))
        
        // Identifiers
        patterns.append(try! TokenPattern(pattern: #"\b[a-zA-Z_][a-zA-Z0-9_]*\b"#, tokenType: .identifier, priority: 30))
        
        // Punctuation
        patterns.append(try! TokenPattern(pattern: #"[{}]"#, tokenType: .brace, priority: 40))
        patterns.append(try! TokenPattern(pattern: #"[\[\]]"#, tokenType: .bracket, priority: 40))
        patterns.append(try! TokenPattern(pattern: #"[()]"#, tokenType: .parenthesis, priority: 40))
        patterns.append(try! TokenPattern(pattern: #";"#, tokenType: .semicolon, priority: 40))
        patterns.append(try! TokenPattern(pattern: #","#, tokenType: .comma, priority: 40))
        patterns.append(try! TokenPattern(pattern: #"\."#, tokenType: .dot, priority: 40))
        
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