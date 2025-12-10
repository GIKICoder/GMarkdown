//
//  GMarkPreprocessor.swift
//  GMarkdown
//
//  Created by GIKI on 2024/7/25.
//

import Foundation

/// Protocol for markdown preprocessors
public protocol GMarkPreprocessorProtocol {
    var priority: Int { get }
    func process(_ markdown: String) -> String
}

/// Main preprocessor manager that handles all preprocessing steps
public class GMarkPreprocessor {
    
    private var processors: [GMarkPreprocessorProtocol] = []
    
    public init() {
        setupDefaultProcessors()
    }
    
    /// Add a custom preprocessor
    public func addProcessor(_ processor: GMarkPreprocessorProtocol) {
        processors.append(processor)
        processors.sort { $0.priority < $1.priority }
    }
    
    /// Remove a processor by type
    public func removeProcessor<T: GMarkPreprocessorProtocol>(ofType type: T.Type) {
        processors.removeAll { processor in
            return processor is T
        }
    }
    
    /// Process markdown through all registered preprocessors
    public func process(_ markdown: String) -> String {
        return processors.reduce(markdown) { result, processor in
            return processor.process(result)
        }
    }
}

// MARK: - Default Preprocessor Implementations

/// Preprocessor for LaTeX mathematical expressions
public class LaTeXPreprocessor: GMarkPreprocessorProtocol {
    
    public let priority: Int = 10
    
    public init() {}
    
    public func process(_ markdown: String) -> String {
        return processLaTeX(markdown)
    }
    
    private func processLaTeX(_ markdown: String) -> String {
        var result = markdown
        
        // Process in two passes:
        // First pass: Match display math ($$...$$) and bracket notation
        // Second pass: Match inline math ($...$) but not where it conflicts with $$
        
        // Pass 1: Display math with $$, \[...\], \(...\)
        let displayPattern = "\\$\\$([\\s\\S]*?)\\$\\$|\\\\\\[([\\s\\S]*?)\\\\\\]|\\\\\\(([\\s\\S]*?)\\\\\\)"
        result = processPattern(displayPattern, in: result, alwaysAccept: true)
        
        // Pass 2: Inline math with single $, but use markers to avoid conflicts
        // We use negative lookbehind and lookahead to ensure $ is not preceded or followed by $
        let inlinePattern = "(?<!\\$)\\$(?!\\$)([^$\\n]+?)(?<!\\$)\\$(?!\\$)"
        result = processPattern(inlinePattern, in: result, alwaysAccept: false)
        
        return result
    }
    
    private func processPattern(_ pattern: String, in markdown: String, alwaysAccept: Bool) -> String {
        var result = markdown
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return result
        }
        
        let nsString = result as NSString
        let range = NSRange(location: 0, length: nsString.length)
        let matches = regex.matches(in: result, options: [], range: range).reversed()
        
        for match in matches {
            let matchRange = match.range
            let matchedString = nsString.substring(with: matchRange)
            
            // Skip if content is too large (potential security issue)
            guard matchedString.count < 3000 else { continue }
            
            // Skip if already wrapped (from previous pass)
            if matchedString.contains("<LaTex>") {
                continue
            }
            
            // For display math, always accept. For inline math, validate
            guard alwaysAccept || isValidLaTeX(matchedString) else { continue }
            
            let wrappedString = wrapLaTeX(matchedString)
            result = (result as NSString).replacingCharacters(in: matchRange, with: wrappedString)
        }
        
        return result
    }
    
    private func isValidLaTeX(_ content: String) -> Bool {
        // For inline math ($...$), apply validation
        // The content here should already have delimiters
        let innerContent: Substring
        if content.hasPrefix("$") && content.hasSuffix("$") {
            innerContent = content.dropFirst().dropLast()
        } else {
            // For other formats, just use the content as-is
            return true
        }
        
        // If empty or just whitespace, not valid LaTeX
        guard !innerContent.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        
        // If content contains table cell delimiters (|), it's very unlikely to be valid inline LaTeX
        if innerContent.contains("|") {
            return false
        }
        
        // Currency pattern: Just digits possibly with decimal point, currency symbols, or simple separators
        // Examples to reject: $20/月, $10, $5.99, $1,000
        let currencyPattern = "^\\s*\\d+([.,]\\d+)?\\s*[/\\-a-zA-Z\\u4e00-\\u9fff]*\\s*$"
        if let currencyRegex = try? NSRegularExpression(pattern: currencyPattern, options: []),
           currencyRegex.firstMatch(in: String(innerContent), options: [], range: NSRange(location: 0, length: innerContent.utf16.count)) != nil {
            return false
        }
        
        // Valid LaTeX should contain at least one of these indicators:
        // - Backslash (LaTeX commands like \alpha, \frac, etc.)
        // - Superscript/subscript (^, _)
        // - Common math operators in context (+, -, *, =, <, > when with letters)
        // - Greek letters or special symbols
        // - Parentheses/brackets with operators
        let hasBackslash = innerContent.contains("\\")
        let hasSuperSubScript = innerContent.contains("^") || innerContent.contains("_")
        let hasLetters = innerContent.rangeOfCharacter(from: CharacterSet.letters) != nil
        
        // If it has backslash (LaTeX command) or super/subscript, it's likely LaTeX
        if hasBackslash || hasSuperSubScript {
            return true
        }
        
        // If it has letters and is not just a simple number/currency, it might be LaTeX
        // This catches expressions like "x + y", "a = b", etc.
        if hasLetters {
            // Check if it contains math-like patterns
            let mathPattern = "[a-zA-Z]\\s*[+\\-*/=<>]|[+\\-*/=<>]\\s*[a-zA-Z]|[a-zA-Z]\\s*\\^|\\^\\s*[a-zA-Z]"
            if let mathRegex = try? NSRegularExpression(pattern: mathPattern, options: []),
               mathRegex.firstMatch(in: String(innerContent), options: [], range: NSRange(location: 0, length: innerContent.utf16.count)) != nil {
                return true
            }
        }
        
        // Default to false for safety - don't treat as LaTeX unless we're confident
        return false
    }
    
    private func wrapLaTeX(_ content: String) -> String {
        let lines = content.components(separatedBy: .newlines)
        
        if lines.count > 1 || content.count > 30 {
            // Multi-line or long expressions get newlines for better formatting
            return "\n <LaTex>\(content)</LaTex> \n"
        } else {
            // Inline expressions
            return "<LaTex>\(content)</LaTex>"
        }
    }
}

/// Preprocessor for code blocks formatting
public class CodeBlockPreprocessor: GMarkPreprocessorProtocol {
    
    public let priority: Int = 20
    
    public init() {}
    
    public func process(_ markdown: String) -> String {
        return processCodeBlocks(markdown)
    }
    
    private func processCodeBlocks(_ markdown: String) -> String {
        // Ensure code blocks are on separate lines
        let result = markdown.replacingOccurrences(of: "```", with: "\n```")
        return result
    }
}

/// Preprocessor for image tags formatting
public class ImagePreprocessor: GMarkPreprocessorProtocol {
    
    public let priority: Int = 30
    
    public init() {}
    
    public func process(_ markdown: String) -> String {
        return processImages(markdown)
    }
    
    private func processImages(_ markdown: String) -> String {
        var result = markdown
        
        // Convert <img></img> tags to markdown format with proper spacing
        result = result.replacingOccurrences(of: "<img>", with: "\n\n ![](")
        result = result.replacingOccurrences(of: "</img>", with: ") \n\n")
        
        return result
    }
}
