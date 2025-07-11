import Foundation

/// Universal syntax ink - the main interface for multi-language syntax highlighting
public struct UniversalSyntaxInk {
    private let languageFactory: LanguageFactory
    private let highlighterCache: HighlighterCache
    
    /// Initialize with default languages
    public init() {
        let defaultLanguages: [Language] = [
            JavaScriptLanguage(includeTypeScript: true),
            PythonLanguage(),
            JavaLanguage(),
            CLanguage(includeCPlusPlus: true),
            HTMLLanguage(),
            CSSLanguage(),
            JSONLanguage(),
            MarkdownLanguage(),
            GoLanguage(),
            RustLanguage(),
            PHPLanguage()
        ]
        
        self.languageFactory = LanguageFactory(languages: defaultLanguages)
        self.highlighterCache = HighlighterCache()
    }
    
    /// Initialize with custom languages
    public init(languages: [Language]) {
        self.languageFactory = LanguageFactory(languages: languages)
        self.highlighterCache = HighlighterCache()
    }
    
    /// Create a syntax highlighter for a specific language with caching
    public func highlighter(for languageIdentifier: String, theme: StandardUniversalTheme = DefaultThemes.light) -> UniversalSyntaxHighlighter {
        let cacheKey = "\(languageIdentifier)_\(theme.identifier)"
        
        if let cachedHighlighter = highlighterCache.get(key: cacheKey) {
            return cachedHighlighter
        }
        
        let language = languageFactory.language(for: languageIdentifier)
        let grammar = UniversalGrammar(language: language)
        let highlighter = UniversalSyntaxHighlighter(grammar: grammar, theme: theme)
        
        highlighterCache.set(key: cacheKey, highlighter: highlighter)
        return highlighter
    }
    
    /// Create a syntax highlighter by detecting language from filename with caching
    public func highlighter(forFile filename: String, theme: StandardUniversalTheme = DefaultThemes.light) -> UniversalSyntaxHighlighter {
        let language = languageFactory.detectLanguage(from: filename)
        let cacheKey = "\(language.identifier)_\(theme.identifier)"
        
        if let cachedHighlighter = highlighterCache.get(key: cacheKey) {
            return cachedHighlighter
        }
        
        let grammar = UniversalGrammar(language: language)
        let highlighter = UniversalSyntaxHighlighter(grammar: grammar, theme: theme)
        
        highlighterCache.set(key: cacheKey, highlighter: highlighter)
        return highlighter
    }
    
    /// Get all available languages
    public var availableLanguages: [Language] {
        return languageFactory.availableLanguages
    }
    
    /// Get supported language aliases
    public var supportedLanguageAliases: [String] {
        return languageFactory.supportedAliases
    }
    
    /// Highlight code with automatic language detection (always succeeds with fallback)
    public func highlight(_ code: String, filename: String, theme: StandardUniversalTheme = DefaultThemes.light) -> NSAttributedString {
        let highlighter = self.highlighter(forFile: filename, theme: theme)
        return highlighter.highlight(code)
    }
    
    /// Highlight code with specific language (always succeeds with fallback)
    public func highlight(_ code: String, language: String, theme: StandardUniversalTheme = DefaultThemes.light) -> NSAttributedString {
        let highlighter = self.highlighter(for: language, theme: theme)
        return highlighter.highlight(code)
    }
    
    /// Clear the highlighter cache
    public func clearCache() {
        highlighterCache.clear()
    }
    
    /// Get cache statistics
    public var cacheInfo: (hitCount: Int, missCount: Int, size: Int) {
        return highlighterCache.stats
    }
}

/// Thread-safe cache for syntax highlighters
private final class HighlighterCache {
    private let cache = NSCache<NSString, HighlighterWrapper>()
    private let lock = NSLock()
    private var _hitCount = 0
    private var _missCount = 0
    
    init() {
        cache.countLimit = 50 // Limit cache size
        cache.totalCostLimit = 1024 * 1024 * 10 // 10MB limit
    }
    
    func get(key: String) -> UniversalSyntaxHighlighter? {
        lock.lock()
        defer { lock.unlock() }
        
        let nsKey = NSString(string: key)
        if let wrapper = cache.object(forKey: nsKey) {
            _hitCount += 1
            return wrapper.highlighter
        } else {
            _missCount += 1
            return nil
        }
    }
    
    func set(key: String, highlighter: UniversalSyntaxHighlighter) {
        lock.lock()
        defer { lock.unlock() }
        
        let nsKey = NSString(string: key)
        let wrapper = HighlighterWrapper(highlighter: highlighter)
        cache.setObject(wrapper, forKey: nsKey)
    }
    
    func clear() {
        lock.lock()
        defer { lock.unlock() }
        
        cache.removeAllObjects()
        _hitCount = 0
        _missCount = 0
    }
    
    var stats: (hitCount: Int, missCount: Int, size: Int) {
        lock.lock()
        defer { lock.unlock() }
        
        return (hitCount: _hitCount, missCount: _missCount, size: cache.totalCostLimit)
    }
}

/// Wrapper class for NSCache compatibility
private final class HighlighterWrapper: NSObject {
    let highlighter: UniversalSyntaxHighlighter
    
    init(highlighter: UniversalSyntaxHighlighter) {
        self.highlighter = highlighter
    }
}

/// Convenience extensions for common use cases
public extension UniversalSyntaxInk {
    /// Highlight JavaScript code
    func highlightJavaScript(_ code: String, theme: StandardUniversalTheme = DefaultThemes.light) -> NSAttributedString {
        return highlight(code, language: "javascript", theme: theme)
    }
    
    /// Highlight Python code
    func highlightPython(_ code: String, theme: StandardUniversalTheme = DefaultThemes.light) -> NSAttributedString {
        return highlight(code, language: "python", theme: theme)
    }
    
    /// Highlight Java code
    func highlightJava(_ code: String, theme: StandardUniversalTheme = DefaultThemes.light) -> NSAttributedString {
        return highlight(code, language: "java", theme: theme)
    }
    
    /// Highlight C/C++ code
    func highlightC(_ code: String, theme: StandardUniversalTheme = DefaultThemes.light) -> NSAttributedString {
        return highlight(code, language: "c", theme: theme)
    }
    
    /// Highlight HTML code
    func highlightHTML(_ code: String, theme: StandardUniversalTheme = DefaultThemes.light) -> NSAttributedString {
        return highlight(code, language: "html", theme: theme)
    }
    
    /// Highlight CSS code
    func highlightCSS(_ code: String, theme: StandardUniversalTheme = DefaultThemes.light) -> NSAttributedString {
        return highlight(code, language: "css", theme: theme)
    }
    
    /// Highlight JSON code
    func highlightJSON(_ code: String, theme: StandardUniversalTheme = DefaultThemes.light) -> NSAttributedString {
        return highlight(code, language: "json", theme: theme)
    }
    
    /// Highlight Markdown code
    func highlightMarkdown(_ code: String, theme: StandardUniversalTheme = DefaultThemes.light) -> NSAttributedString {
        return highlight(code, language: "markdown", theme: theme)
    }
    
    /// Highlight Go code
    func highlightGo(_ code: String, theme: StandardUniversalTheme = DefaultThemes.light) -> NSAttributedString {
        return highlight(code, language: "go", theme: theme)
    }
    
    /// Highlight Rust code
    func highlightRust(_ code: String, theme: StandardUniversalTheme = DefaultThemes.light) -> NSAttributedString {
        return highlight(code, language: "rust", theme: theme)
    }
    
    /// Highlight PHP code
    func highlightPHP(_ code: String, theme: StandardUniversalTheme = DefaultThemes.light) -> NSAttributedString {
        return highlight(code, language: "php", theme: theme)
    }
    
    /// Highlight code with automatic language detection from common patterns
    func highlightWithAutoDetection(_ code: String, theme: StandardUniversalTheme = DefaultThemes.light) -> NSAttributedString {
        let detectedLanguage = detectLanguageFromCode(code)
        return highlight(code, language: detectedLanguage, theme: theme)
    }
    
    /// Simple language detection from code content
    private func detectLanguageFromCode(_ code: String) -> String {
        let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowerCode = trimmedCode.lowercased()
        
        // JSON detection
        if (lowerCode.hasPrefix("{") && lowerCode.hasSuffix("}")) || 
           (lowerCode.hasPrefix("[") && lowerCode.hasSuffix("]")) {
            return "json"
        }
        
        // HTML detection
        if lowerCode.hasPrefix("<") && (lowerCode.contains("</") || lowerCode.contains("/>")) {
            return "html"
        }
        
        // CSS detection
        if lowerCode.contains("{") && lowerCode.contains("}") && lowerCode.contains(":") {
            return "css"
        }
        
        // Python detection
        if lowerCode.contains("def ") || lowerCode.contains("import ") || lowerCode.contains("from ") {
            return "python"
        }
        
        // JavaScript detection
        if lowerCode.contains("function") || lowerCode.contains("var ") || lowerCode.contains("let ") || lowerCode.contains("const ") {
            return "javascript"
        }
        
        // Java detection
        if lowerCode.contains("public class") || lowerCode.contains("public static void main") {
            return "java"
        }
        
        // C/C++ detection
        if lowerCode.contains("#include") || lowerCode.contains("int main") {
            return "c"
        }
        
        // Go detection
        if lowerCode.contains("package main") || lowerCode.contains("func main") {
            return "go"
        }
        
        // Rust detection
        if lowerCode.contains("fn main") || lowerCode.contains("use std") {
            return "rust"
        }
        
        // PHP detection
        if lowerCode.contains("<?php") || lowerCode.contains("function ") {
            return "php"
        }
        
        // Markdown detection
        if lowerCode.contains("#") || lowerCode.contains("**") || lowerCode.contains("*") {
            return "markdown"
        }
        
        // Default to plain text
        return "plain-text"
    }
}