//
//  Syntect.swift
//  Syntect
//
//  High-performance syntax highlighter with caching and rich configuration
//

import Foundation
import UIKit

// MARK: - C Function Declarations

/// C structures for FFI
struct HighlightResult {
    let text: UnsafeMutablePointer<CChar>
    let ranges: UnsafeMutablePointer<StyleRange>
    let range_count: Int
}

struct StyleRange {
    let start: Int
    let end: Int
    let foreground: UInt32
    let background: UInt32
    let font_style: UInt32
}

/// C function declarations
@_silgen_name("syntect_initialize")
func syntect_initialize() -> Bool

@_silgen_name("syntect_highlight_fast")
func syntect_highlight_fast(_ text: UnsafePointer<CChar>, _ syntax: UnsafePointer<CChar>, _ theme: UnsafePointer<CChar>) -> UnsafeMutablePointer<HighlightResult>?

@_silgen_name("syntect_get_syntax_by_extension")
func syntect_get_syntax_by_extension(_ extension: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar>?

@_silgen_name("syntect_get_syntax_names")
func syntect_get_syntax_names() -> UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?

@_silgen_name("syntect_get_theme_names")
func syntect_get_theme_names() -> UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?

@_silgen_name("syntect_clear_cache")
func syntect_clear_cache()

@_silgen_name("syntect_cache_size")
func syntect_cache_size() -> Int

@_silgen_name("syntect_highlight_result_free")
func syntect_highlight_result_free(_ result: UnsafeMutablePointer<HighlightResult>)

@_silgen_name("syntect_free_string_array")
func syntect_free_string_array(_ strings: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>)

/// Configuration options for syntax highlighting
public struct SyntectConfig {
    public let fontSize: CGFloat
    public let fontFamily: String
    public let lineSpacing: CGFloat
    public let enableBold: Bool
    public let enableItalic: Bool
    public let enableUnderline: Bool
    public let cacheSize: Int
    
    public init(
        fontSize: CGFloat = 14,
        fontFamily: String = "Menlo",
        lineSpacing: CGFloat = 1.2,
        enableBold: Bool = true,
        enableItalic: Bool = true,
        enableUnderline: Bool = false,
        cacheSize: Int = 50
    ) {
        self.fontSize = fontSize
        self.fontFamily = fontFamily
        self.lineSpacing = lineSpacing
        self.enableBold = enableBold
        self.enableItalic = enableItalic
        self.enableUnderline = enableUnderline
        self.cacheSize = cacheSize
    }
    
    /// Preset configurations
    public static let `default` = SyntectConfig()
    public static let compact = SyntectConfig(fontSize: 12, lineSpacing: 1.1)
    public static let large = SyntectConfig(fontSize: 16, lineSpacing: 1.3)
    public static let minimal = SyntectConfig(enableBold: false, enableItalic: false, cacheSize: 10)
}

/// High-performance syntax highlighter with intelligent caching
@objc public class Syntect: NSObject {
    
    public var config: SyntectConfig {
        didSet {
            if config.cacheSize != oldValue.cacheSize {
                clearCache()
            }
        }
    }
    
    private var isInitialized = false
    
    /// Shared instance for convenience
    @objc public static let shared = Syntect()
    
    /// Initialize with default configuration
    public override init() {
        self.config = .default
        super.init()
        initializeIfNeeded()
    }
    
    /// Initialize with custom configuration
    public init(config: SyntectConfig) {
        self.config = config
        super.init()
        initializeIfNeeded()
    }
    
    private func initializeIfNeeded() {
        if !isInitialized {
            syntect_initialize()
            isInitialized = true
        }
    }
    
    /// Fast highlight with automatic caching - preferred method for real-time scenarios
    @objc public func highlight(_ text: String, language: String, theme: String = "Monokai") -> Foundation.NSAttributedString {
        initializeIfNeeded()
        let languageSyn = Syntect.getLanguage(language)
        return text.withCString { textPtr in
            return languageSyn.withCString { langPtr in
                return theme.withCString { themePtr in
                    guard let result = syntect_highlight_fast(textPtr, langPtr, themePtr) else {
                        return createFallbackAttributedString(text)
                    }
                    
                    defer {
                        syntect_highlight_result_free(result)
                    }
                    
                    return convertToNSAttributedString(result)
                }
            }
        }
    }
    
    /// Batch highlight multiple lines efficiently
    public func highlightLines(_ lines: [String], language: String, theme: String = "InspiredGitHub") -> [Foundation.NSAttributedString] {
        return lines.map { highlight($0, language: language, theme: theme) }
    }
    
    /// Highlight with automatic language detection by file extension
    public func highlightCode(_ text: String, filename: String, theme: String = "InspiredGitHub") -> Foundation.NSAttributedString {
        let ext = (filename as NSString).pathExtension
        let language = Syntect.languageForExtension(ext)
        return highlight(text, language: language, theme: theme)
    }
    
    /// Get syntax name for file extension
    @objc public func syntaxForExtension(_ fileExtension: String) -> String {
        // First try local mapping for common extensions (case-insensitive)
        let language = Syntect.languageForExtension(fileExtension)
        if language != Language.plainText {
            return language
        }
        
        // Fall back to native Rust implementation
        initializeIfNeeded()
        
        return fileExtension.lowercased().withCString { extPtr in
            guard let result = syntect_get_syntax_by_extension(extPtr) else {
                return Language.plainText
            }
            
            defer {
                free(result)
            }
            
            return String(cString: result)
        }
    }
    
    /// Get available syntax names
    @objc public var availableSyntaxes: [String] {
        initializeIfNeeded()
        
        guard let names = syntect_get_syntax_names() else {
            return []
        }
        
        defer {
            syntect_free_string_array(names)
        }
        
        var result: [String] = []
        var index = 0
        
        while let name = names[index] {
            result.append(String(cString: name))
            index += 1
        }
        
        return result
    }
    
    /// Get available theme names
    @objc public var availableThemes: [String] {
        initializeIfNeeded()
        
        guard let names = syntect_get_theme_names() else {
            return []
        }
        
        defer {
            syntect_free_string_array(names)
        }
        
        var result: [String] = []
        var index = 0
        
        while let name = names[index] {
            result.append(String(cString: name))
            index += 1
        }
        
        return result
    }
    
    /// Clear the internal highlighter cache
    @objc public func clearCache() {
        syntect_clear_cache()
    }
    
    /// Get current cache size
    @objc public var cacheSize: Int {
        return syntect_cache_size()
    }
    
    // MARK: - Private Methods
    
    private func convertToNSAttributedString(_ result: UnsafeMutablePointer<HighlightResult>) -> Foundation.NSAttributedString {
        let string = String(cString: result.pointee.text)
        let mutableString = NSMutableAttributedString(string: string)
        
        // Apply base font
        let baseFont = UIFont(name: config.fontFamily, size: config.fontSize) ?? UIFont.systemFont(ofSize: config.fontSize)
        mutableString.addAttribute(.font, value: baseFont, range: NSRange(location: 0, length: string.count))
        
        // Apply line spacing
        if config.lineSpacing != 1.0 {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = config.fontSize * (config.lineSpacing - 1.0)
            mutableString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: string.count))
        }
        
        // Apply syntax highlighting
        let ranges = UnsafeBufferPointer(start: result.pointee.ranges, count: result.pointee.range_count)
        
        for range in ranges {
            let nsRange = Foundation.NSRange(location: range.start, length: range.end - range.start)
            
            // Validate range
            guard nsRange.location + nsRange.length <= string.count else {
                continue
            }
            
            // Apply foreground color
            let color = uiColorFromRGBA(range.foreground)
            print("range.foreground: \(range.foreground)")
            mutableString.addAttribute(.foregroundColor, value: color, range: nsRange)
            
            // Apply background color if needed
            if range.background != 0 {
                let bgColor = uiColorFromRGBA(range.background)
                mutableString.addAttribute(.backgroundColor, value: bgColor, range: nsRange)
            }
            
            // Apply font styles
            if range.font_style != 0 {
                let font = fontFromStyle(range.font_style, baseSize: config.fontSize)
                mutableString.addAttribute(.font, value: font, range: nsRange)
            }
        }
        
        return mutableString
    }
    
    private func uiColorFromRGBA(_ rgba: UInt32) -> UIColor {
        let red = CGFloat((rgba >> 24) & 0xFF) / 255.0
        let green = CGFloat((rgba >> 16) & 0xFF) / 255.0
        let blue = CGFloat((rgba >> 8) & 0xFF) / 255.0
        let alpha = CGFloat(rgba & 0xFF) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    private func fontFromStyle(_ fontStyle: UInt32, baseSize: CGFloat) -> UIFont {
        let baseFont = UIFont(name: config.fontFamily, size: baseSize) ?? UIFont.systemFont(ofSize: baseSize)
        
        var traits: UIFontDescriptor.SymbolicTraits = []
        
        if config.enableBold && (fontStyle & 1 != 0) {
            traits.insert(.traitBold)
        }
        
        if config.enableItalic && (fontStyle & 2 != 0) {
            traits.insert(.traitItalic)
        }
        
        if !traits.isEmpty {
            if let descriptor = baseFont.fontDescriptor.withSymbolicTraits(traits) {
                return UIFont(descriptor: descriptor, size: baseSize)
            }
        }
        
        return baseFont
    }
    
    private func createFallbackAttributedString(_ text: String) -> Foundation.NSAttributedString {
        let font = UIFont(name: config.fontFamily, size: config.fontSize) ?? UIFont.systemFont(ofSize: config.fontSize)
        return NSAttributedString(string: text, attributes: [.font: font])
    }
}

// MARK: - Constants and Convenience

public extension Syntect {
    
    /// Popular programming languages
    struct Language {
        public static let swift = "Swift"
        public static let objectiveC = "Objective-C"
        public static let javascript = "JavaScript"
        public static let typescript = "TypeScript"
        public static let python = "Python"
        public static let rust = "Rust"
        public static let go = "Go"
        public static let java = "Java"
        public static let kotlin = "Kotlin"
        public static let cpp = "C++"
        public static let c = "C"
        public static let ruby = "Ruby"
        public static let php = "PHP"
        public static let html = "HTML"
        public static let css = "CSS"
        public static let scss = "SCSS"
        public static let sass = "Sass"
        public static let less = "Less"
        public static let json = "JSON"
        public static let xml = "XML"
        public static let yaml = "YAML"
        public static let markdown = "Markdown"
        public static let sql = "SQL"
        public static let bash = "Bash"
        public static let shell = "Shell Script"
        public static let plainText = "Plain Text"
        public static let dart = "Dart"
        public static let flutter = "Dart"
        public static let csharp = "C#"
        public static let fsharp = "F#"
        public static let vbnet = "VB.NET"
        public static let perl = "Perl"
        public static let lua = "Lua"
        public static let r = "R"
        public static let scala = "Scala"
        public static let haskell = "Haskell"
        public static let clojure = "Clojure"
        public static let elixir = "Elixir"
        public static let erlang = "Erlang"
        public static let groovy = "Groovy"
        public static let powershell = "PowerShell"
        public static let dockerfile = "Dockerfile"
        public static let makefile = "Makefile"
        public static let cmake = "CMake"
        public static let toml = "TOML"
        public static let ini = "INI"
        public static let properties = "Properties"
        public static let vue = "Vue"
        public static let svelte = "Svelte"
        public static let jsx = "JSX"
        public static let tsx = "TSX"
    }
    
    /// Popular themes
    struct Theme {
        public static let inspiredGitHub = "InspiredGitHub"
        public static let oceanDark = "base16-ocean.dark"
        public static let oceanLight = "base16-ocean.light"
        public static let solarizedDark = "Solarized (dark)"
        public static let solarizedLight = "Solarized (light)"
        public static let monokaiDark = "Monokai"
        public static let tomorrowNight = "Tomorrow Night"
    }
    
    /// File extension to language mapping (case-insensitive)
    static let extensionMapping: [String: String] = [
        // Mobile Development
        "swift": Language.swift,
        "m": Language.objectiveC,
        "mm": Language.objectiveC,
        "java": Language.java,
        "kt": Language.kotlin,
        "kts": Language.kotlin,
        "dart": Language.dart,
        
        // Web Development - JavaScript/TypeScript
        "js": Language.javascript,
        "jsx": Language.jsx,
        "mjs": Language.javascript,
        "cjs": Language.javascript,
        "ts": Language.typescript,
        "tsx": Language.tsx,
        
//        // Web Development - Markup & Styling
        "html": Language.html,
        "htm": Language.html,
        "xhtml": Language.html,
        "css": Language.css,
        "scss": Language.scss,
        "sass": Language.sass,
        "less": Language.less,
        "vue": Language.vue,
        "svelte": Language.svelte,
        
        // System Languages
        "c": Language.c,
        "cpp": Language.cpp,
        "cc": Language.cpp,
        "cxx": Language.cpp,
        "c++": Language.cpp,
        "hpp": Language.cpp,
        "hxx": Language.cpp,
        "h++": Language.cpp,
        "rs": Language.rust,
        "go": Language.go,
        "cs": Language.csharp,
        "fs": Language.fsharp,
        "vb": Language.vbnet,
        
        // Scripting Languages
        "py": Language.python,
        "pyw": Language.python,
        "pyi": Language.python,
        "rb": Language.ruby,
        "rbw": Language.ruby,
        "php": Language.php,
        "php3": Language.php,
        "php4": Language.php,
        "php5": Language.php,
        "phtml": Language.php,
        "pl": Language.perl,
        "pm": Language.perl,
        "lua": Language.lua,
        "scala": Language.scala,
        "sc": Language.scala,
        "hs": Language.haskell,
        "lhs": Language.haskell,
        "clj": Language.clojure,
        "cljs": Language.clojure,
        "cljc": Language.clojure,
        "ex": Language.elixir,
        "exs": Language.elixir,
        "erl": Language.erlang,
        "hrl": Language.erlang,
        "gradle": Language.groovy,
        
        // Shell & Scripts
        "sh": Language.bash,
        "bash": Language.bash,
        "zsh": Language.bash,
        "fish": Language.bash,
        "ps1": Language.powershell,
        "psm1": Language.powershell,
        "psd1": Language.powershell,
        
        // Data & Configuration
        "json": Language.json,
        "jsonc": Language.json,
        "xml": Language.xml,
        "xsl": Language.xml,
        "xslt": Language.xml,
        "xsd": Language.xml,
        "yaml": Language.yaml,
        "yml": Language.yaml,
        "toml": Language.toml,
        "ini": Language.ini,
        "cfg": Language.ini,
        "conf": Language.ini,
        "properties": Language.properties,
        
        // Documentation & Text
        "md": Language.markdown,
        "markdown": Language.markdown,
        "mdown": Language.markdown,
        "mkd": Language.markdown,
        "txt": Language.plainText,
        "text": Language.plainText,
        
        // Database
        "sql": Language.sql,
        "mysql": Language.sql,
        "pgsql": Language.sql,
        "sqlite": Language.sql,
        
        // Build & DevOps
        "dockerfile": Language.dockerfile,
        "makefile": Language.makefile,
        "cmake": Language.cmake,
        "mk": Language.makefile,
        "mak": Language.makefile,
        
        // Language names (lowercase) - for direct language lookup
        "objective-c": Language.objectiveC,
        "objc": Language.objectiveC,
        "javascript": Language.javascript,
        "typescript": Language.typescript,
        "python": Language.python,
        "rust": Language.rust,
        "kotlin": Language.kotlin,
        "ruby": Language.ruby,
        "shell": Language.shell,
        "shell script": Language.shell,
        "plaintext": Language.plainText,
        "flutter": Language.flutter,
        "csharp": Language.csharp,
        "fsharp": Language.fsharp,
        "vbnet": Language.vbnet,
        "perl": Language.perl,
        "haskell": Language.haskell,
        "clojure": Language.clojure,
        "elixir": Language.elixir,
        "erlang": Language.erlang,
        "groovy": Language.groovy,
        "powershell": Language.powershell,
    ]



    
    /// 🎯 统一查找方法：既支持文件扩展名也支持语言名称 (case-insensitive)
    /// - Parameter input: 文件扩展名（如 "swift", "py", "js"）或语言名称（如 "Swift", "Python", "JavaScript"）
    /// - Returns: 对应的标准语言名称，如果未找到则返回 "Plain Text"
    static func getLanguage(_ input: String) -> String {
        let lowercaseInput = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 直接查找映射表
        if let language = extensionMapping[lowercaseInput] {
            return language
        }
        
        // 如果没找到，尝试匹配语言名称的小写版本
        let languageValues = Set(extensionMapping.values)
        for language in languageValues {
            if language.lowercased() == lowercaseInput {
                return language
            }
        }
        
        // 特殊处理一些常见的别名
        switch lowercaseInput {
        case "js":
            return Language.javascript
        case "ts":
            return Language.typescript
        case "py":
            return Language.python
        case "rb":
            return Language.ruby
        case "cpp", "c++":
            return Language.cpp
        case "cs", "c#":
            return Language.csharp
        case "fs", "f#":
            return Language.fsharp
        case "objc", "objective-c":
            return Language.objectiveC
        case "sh", "bash":
            return Language.bash
        case "ps1", "powershell":
            return Language.powershell
        case "md", "markdown":
            return Language.markdown
        case "yml", "yaml":
            return Language.yaml
        case "txt", "text", "plain text", "plaintext":
            return Language.plainText
        default:
            return Language.plainText
        }
    }
    
    /// Get language for file extension (case-insensitive)
    static func languageForExtension(_ fileExtension: String) -> String {
        return getLanguage(fileExtension)
    }
    
    /// Get language by name (case-insensitive)
    static func languageByName(_ languageName: String) -> String {
        return getLanguage(languageName)
    }
    
    /// 从文件名获取语言（自动提取扩展名）
    /// - Parameter fileName: 文件名（如 "main.swift", "index.html"）
    /// - Returns: 对应的标准语言名称
    static func languageForFileName(_ fileName: String) -> String {
        let fileExtension = (fileName as NSString).pathExtension
        return getLanguage(fileExtension)
    }
    
    /// Get all supported file extensions (excluding language names)
    static var supportedExtensions: [String] {
        let languageNames = Set([
            "objective-c", "objc", "javascript", "typescript", "python", "rust", "kotlin",
            "ruby", "shell", "shell script", "plain text", "plaintext", "flutter",
            "csharp", "fsharp", "vb.net", "vbnet", "perl", "haskell", "clojure",
            "elixir", "erlang", "groovy", "powershell"
        ])
        
        return Array(extensionMapping.keys)
            .filter { !languageNames.contains($0) }
            .sorted()
    }
    
    /// Get all supported language names
    static var supportedLanguages: [String] {
        return Array(Set(extensionMapping.values)).sorted()
    }
    
    /// Check if extension or language name is supported
    static func isSupported(_ input: String) -> Bool {
        return getLanguage(input) != Language.plainText || input.lowercased() == "plain text" || input.lowercased() == "plaintext"
    }
    
    /// Check if extension is supported
    static func isExtensionSupported(_ fileExtension: String) -> Bool {
        return isSupported(fileExtension)
    }
    
    /// Check if language name is supported
    static func isLanguageSupported(_ languageName: String) -> Bool {
        return isSupported(languageName)
    }
}


// MARK: - Real-time Highlighting Support

public extension Syntect {
    
    /// Optimized for real-time typing scenarios
    func highlightForRealTime(_ text: String, language: String, theme: String = "InspiredGitHub") -> Foundation.NSAttributedString {
        // Use the same fast highlight method, optimized for real-time use
        return highlight(text, language: language, theme: theme)
    }
    
    /// Preload languages for better real-time performance
    func preloadLanguages(_ languages: [String], theme: String = "InspiredGitHub") {
        for language in languages {
            // Trigger cache creation with empty string
            _ = highlight("", language: language, theme: theme)
        }
    }
    
    /// Performance statistics
    var performanceStats: (cacheHits: Int, cacheSize: Int) {
        return (cacheHits: 0, cacheSize: cacheSize) // Cache hits would need to be tracked in Rust
    }
}
