import Foundation

/// Markdown language implementation
public struct MarkdownLanguage: Language {
    public let identifier = "markdown"
    public let fileExtensions = ["md", "markdown", "mdown", "mkdn", "mkd", "mdx"]
    private let tokenPatterns: [TokenPattern]
    
    public init() {
        var patterns: [TokenPattern] = []
        
        // Code blocks (highest priority)
        patterns.append(try! TokenPattern(pattern: #"```[\s\S]*?```"#, tokenType: .markupCode, priority: 100))
        patterns.append(try! TokenPattern(pattern: #"~~~[\s\S]*?~~~"#, tokenType: .markupCode, priority: 100))
        
        // Inline code
        patterns.append(try! TokenPattern(pattern: #"`[^`\n]+`"#, tokenType: .markupCode, priority: 95))
        
        // Headers
        patterns.append(try! TokenPattern(pattern: #"^#{1,6}\s+.*$"#, tokenType: .markupHeading, priority: 90))
        patterns.append(try! TokenPattern(pattern: #"^.+\n=+$"#, tokenType: .markupHeading, priority: 90))
        patterns.append(try! TokenPattern(pattern: #"^.+\n-+$"#, tokenType: .markupHeading, priority: 90))
        
        // Bold and italic
        patterns.append(try! TokenPattern(pattern: #"\*\*\*[^*]+\*\*\*"#, tokenType: .markupBold, priority: 85))
        patterns.append(try! TokenPattern(pattern: #"___[^_]+___"#, tokenType: .markupBold, priority: 85))
        patterns.append(try! TokenPattern(pattern: #"\*\*[^*]+\*\*"#, tokenType: .markupBold, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"__[^_]+__"#, tokenType: .markupBold, priority: 80))
        patterns.append(try! TokenPattern(pattern: #"\*[^*]+\*"#, tokenType: .markupItalic, priority: 75))
        patterns.append(try! TokenPattern(pattern: #"_[^_]+_"#, tokenType: .markupItalic, priority: 75))
        
        // Strikethrough
        patterns.append(try! TokenPattern(pattern: #"~~[^~]+~~"#, tokenType: .markupItalic, priority: 70))
        
        // Links
        patterns.append(try! TokenPattern(pattern: #"\[([^\]]*)\]\(([^)]+)\)"#, tokenType: .markupLink, priority: 85))
        patterns.append(try! TokenPattern(pattern: #"\[([^\]]*)\]\[([^\]]*)\]"#, tokenType: .markupLink, priority: 85))
        patterns.append(try! TokenPattern(pattern: #"!?\[([^\]]*)\]:\s*(.+)"#, tokenType: .markupLink, priority: 85))
        
        // Images
        patterns.append(try! TokenPattern(pattern: #"!\[([^\]]*)\]\(([^)]+)\)"#, tokenType: .markupLink, priority: 85))
        
        // Blockquotes
        patterns.append(try! TokenPattern(pattern: #"^>\s*.*$"#, tokenType: .markupQuote, priority: 80))
        
        // Lists
        patterns.append(try! TokenPattern(pattern: #"^[ \t]*[*+-]\s+"#, tokenType: .markupList, priority: 75))
        patterns.append(try! TokenPattern(pattern: #"^[ \t]*\d+\.\s+"#, tokenType: .markupList, priority: 75))
        
        // Horizontal rules
        patterns.append(try! TokenPattern(pattern: #"^[ \t]*[-*_]{3,}[ \t]*$"#, tokenType: .punctuation, priority: 70))
        
        // HTML tags (in markdown)
        patterns.append(try! TokenPattern(pattern: #"<[^>]+>"#, tokenType: .htmlTag, priority: 60))
        
        // Escape sequences
        patterns.append(try! TokenPattern(pattern: #"\\[\\`*_{}\[\]()#+\-.!]"#, tokenType: .stringLiteral, priority: 55))
        
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