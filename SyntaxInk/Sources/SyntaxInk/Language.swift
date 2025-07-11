import Foundation

/// A universal language protocol for multi-language syntax highlighting
public protocol Language: Sendable {
    /// The identifier for this language
    var identifier: String { get }
    
    /// File extensions supported by this language
    var fileExtensions: [String] { get }
    
    /// Tokenizes the given source code
    func tokenize(_ code: String) -> [UniversalToken]
}

/// A universal token type that can represent tokens from any programming language
public struct UniversalToken: Sendable {
    /// The type of token
    public let type: TokenType
    
    /// The text content of the token
    public let text: String
    
    /// The range of the token in the source code
    public let range: NSRange
    
    /// Language-specific metadata
    public let metadata: [String: String]
    
    public init(type: TokenType, text: String, range: NSRange, metadata: [String: String] = [:]) {
        self.type = type
        self.text = text
        self.range = range
        self.metadata = metadata
    }
}

/// Universal token types that work across all programming languages
public enum TokenType: String, CaseIterable, Sendable {
    // Basic types
    case plainText
    case whitespace
    case newline
    
    // Comments
    case lineComment
    case blockComment
    case docComment
    
    // Literals
    case stringLiteral
    case numberLiteral
    case booleanLiteral
    case nullLiteral
    case characterLiteral
    case regexLiteral
    
    // Keywords
    case keyword
    case controlKeyword
    case declarationKeyword
    case modifier
    case `operator`
    
    // Identifiers
    case identifier
    case functionName
    case methodName
    case propertyName
    case variableName
    case parameterName
    case typeName
    case className
    case interfaceName
    case enumName
    case structName
    case protocolName
    case namespaceName
    case moduleName
    case packageName
    
    // Symbols
    case punctuation
    case bracket
    case brace
    case parenthesis
    case delimiter
    case semicolon
    case comma
    case dot
    case colon
    
    // Preprocessor/Directives
    case preprocessor
    case directive
    case annotation
    case attribute
    case decorator
    
    // Markup (for Markdown, HTML, etc.)
    case markupHeading
    case markupBold
    case markupItalic
    case markupCode
    case markupLink
    case markupList
    case markupQuote
    case htmlTag
    case htmlAttribute
    case htmlAttributeValue
    
    // Language-specific
    case generic
    case template
    case macro
    case label
    case constant
    case builtin
    case error
    case warning
    
    // JSON specific
    case jsonKey
    case jsonValue
    
    // CSS specific
    case cssSelector
    case cssProperty
    case cssValue
    case cssUnit
    
    // SQL specific (for future extension)
    case sqlKeyword
    case sqlFunction
    case sqlTable
    case sqlColumn
    
    // Plain text for fallback
    case fallbackText
}

/// A regex-based language implementation for languages without native parsers
public struct RegexLanguage: Language {
    public let identifier: String
    public let fileExtensions: [String]
    private let tokenPatterns: [TokenPattern]
    
    public init(identifier: String, fileExtensions: [String], tokenPatterns: [TokenPattern]) {
        self.identifier = identifier
        self.fileExtensions = fileExtensions
        self.tokenPatterns = tokenPatterns.sorted { $0.priority > $1.priority }
    }
    
    public func tokenize(_ code: String) -> [UniversalToken] {
        var tokens: [UniversalToken] = []
        let nsString = code as NSString
        var position = 0
        
        while position < nsString.length {
            var matched = false
            
            for pattern in tokenPatterns {
                let searchRange = NSRange(location: position, length: nsString.length - position)
                if let match = pattern.regex.firstMatch(in: code, options: [], range: searchRange),
                   match.range.location == position {
                    
                    let tokenText = nsString.substring(with: match.range)
                    let token = UniversalToken(
                        type: pattern.tokenType,
                        text: tokenText,
                        range: match.range,
                        metadata: pattern.metadata
                    )
                    tokens.append(token)
                    position = match.range.location + match.range.length
                    matched = true
                    break
                }
            }
            
            if !matched {
                // Handle unmatched character as plain text
                let char = nsString.substring(with: NSRange(location: position, length: 1))
                let token = UniversalToken(
                    type: .plainText,
                    text: char,
                    range: NSRange(location: position, length: 1)
                )
                tokens.append(token)
                position += 1
            }
        }
        
        return tokens
    }
}

/// A pattern for matching tokens in regex-based languages
public struct TokenPattern: Sendable {
    public let regex: NSRegularExpression
    public let tokenType: TokenType
    public let priority: Int
    public let metadata: [String: String]
    
    public init(pattern: String, tokenType: TokenType, priority: Int = 0, metadata: [String: String] = [:]) throws {
        self.regex = try NSRegularExpression(pattern: pattern, options: [])
        self.tokenType = tokenType
        self.priority = priority
        self.metadata = metadata
    }
    
    public init(regex: NSRegularExpression, tokenType: TokenType, priority: Int = 0, metadata: [String: String] = [:]) {
        self.regex = regex
        self.tokenType = tokenType
        self.priority = priority
        self.metadata = metadata
    }
}

/// Language factory for creating language instances
public final class LanguageFactory: Sendable {
    private let languages: [String: Language]
    private let languageAliases: [String: String]
    private let fallbackLanguage: Language
    
    public init(languages: [Language]) {
        var languageDict: [String: Language] = [:]
        
        // Create fallback language for unsupported languages
        let fallback = PlainTextLanguage()
        self.fallbackLanguage = fallback
        
        // Register all languages
        for language in languages {
            languageDict[language.identifier] = language
            for ext in language.fileExtensions {
                languageDict[ext] = language
            }
        }
        
        // Add fallback language
        languageDict[fallback.identifier] = fallback
        
        self.languages = languageDict
        self.languageAliases = Self.createLanguageAliases()
    }
    
    /// Get language by identifier with alias support and fallback
    public func language(for identifier: String) -> Language {
        let normalizedId = identifier.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Direct match
        if let language = languages[normalizedId] {
            return language
        }
        
        // Alias match
        if let aliasTarget = languageAliases[normalizedId],
           let language = languages[aliasTarget] {
            return language
        }
        
        // Fallback to plain text
        return fallbackLanguage
    }
    
    /// Detect language from file extension with fallback
    public func detectLanguage(from filename: String) -> Language {
        let ext = URL(fileURLWithPath: filename).pathExtension.lowercased()
        return languages[ext] ?? fallbackLanguage
    }
    
    /// Get all available languages
    public var availableLanguages: [Language] {
        return Array(Set(languages.values.map { $0.identifier })).compactMap { languages[$0] }
    }
    
    /// Get all supported language aliases
    public var supportedAliases: [String] {
        return Array(languageAliases.keys).sorted()
    }
    
    /// Create comprehensive language aliases mapping
    private static func createLanguageAliases() -> [String: String] {
        return [
            // JavaScript variants
            "js": "javascript-typescript",
            "jsx": "javascript-typescript",
            "ts": "javascript-typescript",
            "tsx": "javascript-typescript",
            "javascript": "javascript-typescript",
            "typescript": "javascript-typescript",
            "vue": "javascript-typescript",
            "svelte": "javascript-typescript",
            "react": "javascript-typescript",
            "node": "javascript-typescript",
            "nodejs": "javascript-typescript",
            "es6": "javascript-typescript",
            "es2015": "javascript-typescript",
            "es2017": "javascript-typescript",
            "es2018": "javascript-typescript",
            "es2019": "javascript-typescript",
            "es2020": "javascript-typescript",
            "es2021": "javascript-typescript",
            "es2022": "javascript-typescript",
            "mjs": "javascript-typescript",
            "cjs": "javascript-typescript",
            
            // Python variants
            "py": "python",
            "python3": "python",
            "py3": "python",
            "python2": "python",
            "py2": "python",
            "pyw": "python",
            "pyi": "python",
            "pyc": "python",
            "pyo": "python",
            "pyd": "python",
            
            // Java variants
            "java": "java",
            "jar": "java",
            "class": "java",
            "kt": "java", // Kotlin treated as Java-like
            "kotlin": "java",
            "scala": "java",
            "clojure": "java",
            "clj": "java",
            "groovy": "java",
            
            // C/C++ variants
            "c": "c-cpp",
            "cc": "c-cpp",
            "cpp": "c-cpp",
            "cxx": "c-cpp",
            "c++": "c-cpp",
            "h": "c-cpp",
            "hpp": "c-cpp",
            "hxx": "c-cpp",
            "h++": "c-cpp",
            "objc": "c-cpp",
            "objective-c": "c-cpp",
            "m": "c-cpp",
            "mm": "c-cpp",
            
            // HTML/CSS variants
            "html": "html",
            "htm": "html",
            "xhtml": "html",
            "xml": "html",
            "svg": "html",
            "css": "css",
            "scss": "css",
            "sass": "css",
            "less": "css",
            "stylus": "css",
            "styl": "css",
            
            // Go variants
            "go": "go",
            "golang": "go",
            
            // Rust variants
            "rs": "rust",
            "rust": "rust",
            
            // PHP variants
            "php": "php",
            "php3": "php",
            "php4": "php",
            "php5": "php",
            "php7": "php",
            "php8": "php",
            "phtml": "php",
            
            // Shell/Bash variants
            "bash": "plain-text",
            "sh": "plain-text",
            "shell": "plain-text",
            "zsh": "plain-text",
            "fish": "plain-text",
            "powershell": "plain-text",
            "ps1": "plain-text",
            "cmd": "plain-text",
            "bat": "plain-text",
            "batch": "plain-text",
            
            // Configuration formats
            "yaml": "plain-text",
            "yml": "plain-text",
            "json": "json",
            "json5": "json",
            "jsonc": "json",
            "toml": "plain-text",
            "ini": "plain-text",
            "conf": "plain-text",
            "config": "plain-text",
            "env": "plain-text",
            "dotenv": "plain-text",
            "properties": "plain-text",
            
            // Markdown variants
            "md": "markdown",
            "markdown": "markdown",
            "mdown": "markdown",
            "mkdn": "markdown",
            "mkd": "markdown",
            "mdwn": "markdown",
            "mdtxt": "markdown",
            "mdtext": "markdown",
            "rmd": "markdown",
            
            // Database
            "sql": "plain-text",
            "mysql": "plain-text",
            "postgresql": "plain-text",
            "postgres": "plain-text",
            "sqlite": "plain-text",
            "plsql": "plain-text",
            "tsql": "plain-text",
            
            // Other common languages
            "ruby": "plain-text",
            "rb": "plain-text",
            "perl": "plain-text",
            "pl": "plain-text",
            "lua": "plain-text",
            "r": "plain-text",
            "swift": "plain-text",
            "dart": "plain-text",
            "elixir": "plain-text",
            "ex": "plain-text",
            "erlang": "plain-text",
            "erl": "plain-text",
            "haskell": "plain-text",
            "hs": "plain-text",
            "crystal": "plain-text",
            "cr": "plain-text",
            "zig": "plain-text",
            "nim": "plain-text",
            "julia": "plain-text",
            "jl": "plain-text",
            "matlab": "plain-text",
            "octave": "plain-text",
            "fortran": "plain-text",
            "f90": "plain-text",
            "f95": "plain-text",
            "pascal": "plain-text",
            "delphi": "plain-text",
            "ada": "plain-text",
            "d": "plain-text",
            "v": "plain-text",
            "odin": "plain-text",
            
            // Assembly
            "asm": "plain-text",
            "assembly": "plain-text",
            "x86asm": "plain-text",
            "arm": "plain-text",
            "mips": "plain-text",
            "nasm": "plain-text",
            "gas": "plain-text",
            
            // Documentation
            "tex": "plain-text",
            "latex": "plain-text",
            "bibtex": "plain-text",
            "rst": "plain-text",
            "restructuredtext": "plain-text",
            "asciidoc": "plain-text",
            "adoc": "plain-text",
            "textile": "plain-text",
            "wiki": "plain-text",
            "mediawiki": "plain-text",
            "org": "plain-text",
            "rtf": "plain-text",
            
            // Build tools
            "makefile": "plain-text",
            "make": "plain-text",
            "cmake": "plain-text",
            "gradle": "plain-text",
            "maven": "plain-text",
            "ant": "plain-text",
            "sbt": "plain-text",
            "bazel": "plain-text",
            "ninja": "plain-text",
            "meson": "plain-text",
            "dockerfile": "plain-text",
            "docker": "plain-text",
            "dockercompose": "plain-text",
            "vagrant": "plain-text",
            "terraform": "plain-text",
            "tf": "plain-text",
            "ansible": "plain-text",
            "puppet": "plain-text",
            "chef": "plain-text",
            "saltstack": "plain-text",
            "salt": "plain-text",
            
            // Plain text fallbacks
            "text": "plain-text",
            "txt": "plain-text",
            "plain": "plain-text",
            "nohighlight": "plain-text",
            "none": "plain-text",
            "log": "plain-text",
            "diff": "plain-text",
            "patch": "plain-text",
            "console": "plain-text",
            "terminal": "plain-text",
            "ansi": "plain-text"
        ]
    }
}

/// Plain text language as fallback
public struct PlainTextLanguage: Language {
    public let identifier = "plain-text"
    public let fileExtensions = ["txt", "text", "log"]
    
    public func tokenize(_ code: String) -> [UniversalToken] {
        // Simple tokenization - just split by whitespace and newlines
        var tokens: [UniversalToken] = []
        let nsString = code as NSString
        let length = nsString.length
        var position = 0
        
        while position < length {
            let remainingRange = NSRange(location: position, length: length - position)
            
            // Find whitespace
            let whitespaceRange = nsString.rangeOfCharacter(from: .whitespacesAndNewlines, options: [], range: remainingRange)
            
            if whitespaceRange.location == position {
                // Current position is whitespace
                let char = nsString.substring(with: NSRange(location: position, length: 1))
                let tokenType: TokenType = char == "\n" ? .newline : .whitespace
                tokens.append(UniversalToken(
                    type: tokenType,
                    text: char,
                    range: NSRange(location: position, length: 1)
                ))
                position += 1
            } else {
                // Find the next whitespace to get the word
                let wordEndLocation = whitespaceRange.location == NSNotFound ? length : whitespaceRange.location
                let wordRange = NSRange(location: position, length: wordEndLocation - position)
                let word = nsString.substring(with: wordRange)
                
                tokens.append(UniversalToken(
                    type: .fallbackText,
                    text: word,
                    range: wordRange
                ))
                position = wordEndLocation
            }
        }
        
        return tokens
    }
}