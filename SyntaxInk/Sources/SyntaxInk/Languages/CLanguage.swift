import Foundation

/// C/C++ language implementation
public struct CLanguage: Language {
    public let identifier: String
    public let fileExtensions: [String]
    private let tokenPatterns: [TokenPattern]
    
    public init(includeCPlusPlus: Bool = true) {
        self.identifier = includeCPlusPlus ? "c-cpp" : "c"
        self.fileExtensions = includeCPlusPlus ? ["c", "cpp", "cc", "cxx", "c++", "h", "hpp", "hxx", "h++"] : ["c", "h"]
        
        var patterns: [TokenPattern] = []
        
        // Comments (highest priority)
        patterns.append(try! TokenPattern(pattern: #"//.*$"#, tokenType: .lineComment, priority: 100))
        patterns.append(try! TokenPattern(pattern: #"/\*[\s\S]*?\*/"#, tokenType: .blockComment, priority: 100))
        
        // Preprocessor directives
        patterns.append(try! TokenPattern(pattern: #"#\s*\w+.*$"#, tokenType: .preprocessor, priority: 95))
        
        // String literals
        patterns.append(try! TokenPattern(pattern: #""(?:[^"\\]|\\.)*""#, tokenType: .stringLiteral, priority: 90))
        patterns.append(try! TokenPattern(pattern: #"'(?:[^'\\]|\\.)*'"#, tokenType: .characterLiteral, priority: 90))
        
        // Numbers
        patterns.append(try! TokenPattern(pattern: #"\b\d+\.?\d*([eE][+-]?\d+)?[fFlL]?\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[xX][0-9a-fA-F]+[uUlL]*\b"#, tokenType: .numberLiteral, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\b0[0-7]+[uUlL]*\b"#, tokenType: .numberLiteral, priority: 80))
        
        // C keywords
        let cKeywords = [
            "auto", "break", "case", "char", "const", "continue", "default", "do", "double", "else", "enum", "extern",
            "float", "for", "goto", "if", "int", "long", "register", "return", "short", "signed", "sizeof", "static",
            "struct", "switch", "typedef", "union", "unsigned", "void", "volatile", "while", "inline", "restrict"
        ]
        
        let cppKeywords = [
            "alignas", "alignof", "and", "and_eq", "asm", "atomic_cancel", "atomic_commit", "atomic_noexcept",
            "bitand", "bitor", "bool", "catch", "char16_t", "char32_t", "class", "compl", "concept", "const_cast",
            "constexpr", "decltype", "delete", "dynamic_cast", "explicit", "export", "false", "friend", "mutable",
            "namespace", "new", "noexcept", "not", "not_eq", "nullptr", "operator", "or", "or_eq", "private",
            "protected", "public", "reinterpret_cast", "requires", "static_assert", "static_cast", "template",
            "this", "thread_local", "throw", "true", "try", "typeid", "typename", "using", "virtual", "wchar_t",
            "xor", "xor_eq", "final", "override", "co_await", "co_return", "co_yield"
        ]
        
        let allKeywords = includeCPlusPlus ? cKeywords + cppKeywords : cKeywords
        let keywordPattern = "\\b(" + allKeywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: keywordPattern, tokenType: .keyword, priority: 70))
        
        // Control flow keywords
        let controlKeywords = ["if", "else", "for", "while", "do", "switch", "case", "default", "break", "continue", "return", "goto"]
        let controlPattern = "\\b(" + controlKeywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: controlPattern, tokenType: .controlKeyword, priority: 72))
        
        // Declaration keywords
        let declKeywords = ["struct", "union", "enum", "typedef", "class", "namespace", "template", "using"]
        let declPattern = "\\b(" + declKeywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: declPattern, tokenType: .declarationKeyword, priority: 72))
        
        // Storage class specifiers
        let storageKeywords = ["auto", "register", "static", "extern", "typedef", "inline", "constexpr", "thread_local"]
        let storagePattern = "\\b(" + storageKeywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: storagePattern, tokenType: .modifier, priority: 68))
        
        // Type qualifiers
        let qualifierKeywords = ["const", "volatile", "restrict", "atomic", "mutable"]
        let qualifierPattern = "\\b(" + qualifierKeywords.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: qualifierPattern, tokenType: .modifier, priority: 68))
        
        // Primitive types
        let primitiveTypes = ["void", "char", "short", "int", "long", "float", "double", "signed", "unsigned", "bool", "wchar_t", "char16_t", "char32_t"]
        let primitivePattern = "\\b(" + primitiveTypes.joined(separator: "|") + ")\\b"
        patterns.append(try! TokenPattern(pattern: primitivePattern, tokenType: .typeName, priority: 68))
        
        // Function names
        patterns.append(try! TokenPattern(pattern: #"\b\w+(?=\s*\()"#, tokenType: .functionName, priority: 55))
        
        // Struct/class names (after struct/class keyword)
        patterns.append(try! TokenPattern(pattern: #"\bstruct\s+(\w+)"#, tokenType: .structName, priority: 65))
        if includeCPlusPlus {
            patterns.append(try! TokenPattern(pattern: #"\bclass\s+(\w+)"#, tokenType: .className, priority: 65))
            patterns.append(try! TokenPattern(pattern: #"\bnamespace\s+(\w+)"#, tokenType: .namespaceName, priority: 65))
        }
        
        // Enum names (after enum keyword)
        patterns.append(try! TokenPattern(pattern: #"\benum\s+(\w+)"#, tokenType: .enumName, priority: 65))
        
        // Constants (all caps)
        patterns.append(try! TokenPattern(pattern: #"\b[A-Z][A-Z0-9_]*\b"#, tokenType: .constant, priority: 50))
        
        // C++ specific features
        if includeCPlusPlus {
            // Templates
            patterns.append(try! TokenPattern(pattern: #"<[^>]+>"#, tokenType: .template, priority: 50))
            
            // Scope resolution operator
            patterns.append(try! TokenPattern(pattern: #"::"#, tokenType: .`operator`, priority: 62))
            
            // Member access operators
            patterns.append(try! TokenPattern(pattern: #"->"#, tokenType: .`operator`, priority: 62))
        }
        
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