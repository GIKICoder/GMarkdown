# SyntaxInk🎨

A powerful, extensible syntax highlighter for Swift that supports multiple programming languages.

## Features

- 🎯 **Multi-language Support**: JavaScript/TypeScript, Python, Java, C/C++, HTML, CSS, JSON, Markdown, Go, Rust, PHP, and Swift
- 🎨 **Universal Theme System**: Consistent theming across all languages with built-in light and dark themes
- 🚀 **High Performance**: Regex-based tokenization optimized for speed
- 🔧 **Extensible Architecture**: Easy to add new languages and custom themes
- 📱 **Cross-platform**: Works on macOS, iOS, tvOS, watchOS, and visionOS
- 🎪 **SwiftUI Ready**: Returns `AttributedString` for seamless integration

## Quick Start

### Universal Multi-Language Highlighter

```swift
import SyntaxInk

let syntaxInk = UniversalSyntaxInk()

// Highlight JavaScript code
let jsCode = """
function greet(name) {
    console.log(`Hello, ${name}!`);
    return true;
}
"""

let highlighted = syntaxInk.highlightJavaScript(jsCode, theme: DefaultThemes.light)
```

### Automatic Language Detection

```swift
let pythonCode = """
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)
"""

// Automatically detect language from filename
let highlighted = syntaxInk.highlight(pythonCode, filename: "example.py")
```

### SwiftUI Integration

```swift
import SwiftUI
import SyntaxInk

struct CodeView: View {
    let syntaxInk = UniversalSyntaxInk()
    
    var body: some View {
        let rustCode = """
        fn main() {
            let name = "World";
            println!("Hello, {}!", name);
        }
        """
        
        let highlighted = syntaxInk.highlightRust(rustCode, theme: DefaultThemes.dark) ?? AttributedString("Error")
        
        ScrollView {
            Text(highlighted)
                .font(.system(.body, design: .monospaced))
                .padding()
                .background(Color.black)
                .cornerRadius(8)
        }
    }
}
```

## Supported Languages

| Language | File Extensions | Features |
|----------|----------------|----------|
| JavaScript/TypeScript | .js, .jsx, .ts, .tsx, .mjs, .cjs | ES6+, JSX, TypeScript types |
| Python | .py, .pyw, .pyi | Python 3.x, decorators, f-strings |
| Java | .java | Modern Java, annotations, generics |
| C/C++ | .c, .cpp, .h, .hpp, .cxx, .hxx | C11, C++20, templates |
| HTML | .html, .htm, .xhtml | HTML5, embedded CSS/JS |
| CSS | .css, .scss, .sass, .less | CSS3, preprocessors |
| JSON | .json, .jsonc, .json5 | Standard JSON, comments |
| Markdown | .md, .markdown, .mdx | CommonMark, code blocks |
| Go | .go | Go 1.21+, generics, channels |
| Rust | .rs | Rust 2021, lifetimes, macros |
| PHP | .php, .phtml | PHP 8.x, namespaces, traits |
| Swift | .swift | Swift 5.9+ (via SwiftSyntax) |

## Themes

### Built-in Themes

```swift
// Light theme (inspired by Xcode)
let highlighted = syntaxInk.highlight(code, theme: DefaultThemes.light)

// Dark theme (inspired by Xcode)
let highlighted = syntaxInk.highlight(code, theme: DefaultThemes.dark)
```

### Custom Themes

```swift
// Create a custom theme based on the light theme
let customTheme = StandardUniversalTheme.lightTheme { builder in
    builder
        .style(for: .keyword) { style in
            style.color = SyntaxColor(red: 0.8, green: 0.2, blue: 0.8) // Purple
            style.font = .system(size: 14, weight: .bold)
        }
        .style(for: .stringLiteral) { style in
            style.color = SyntaxColor(red: 0.0, green: 0.6, blue: 0.0) // Green
        }
}

let highlighted = syntaxInk.highlightJava(javaCode, theme: customTheme)
```

### Theme Builder

```swift
let theme = ThemeBuilder()
    .style(for: .keyword) { style in
        style.color = SyntaxColor(red: 1.0, green: 0.0, blue: 0.0)
        style.font = .system(size: 16, weight: .bold)
    }
    .style(for: .comment) { style in
        style.color = SyntaxColor(red: 0.5, green: 0.5, blue: 0.5)
    }
    .build()
```

## Advanced Usage

### Language-Specific Highlighting

```swift
let syntaxInk = UniversalSyntaxInk()

// Each language has its own method
syntaxInk.highlightJavaScript(jsCode)
syntaxInk.highlightPython(pythonCode)
syntaxInk.highlightJava(javaCode)
syntaxInk.highlightC(cppCode)
syntaxInk.highlightHTML(htmlCode)
syntaxInk.highlightCSS(cssCode)
syntaxInk.highlightJSON(jsonCode)
syntaxInk.highlightMarkdown(mdCode)
syntaxInk.highlightGo(goCode)
syntaxInk.highlightRust(rustCode)
syntaxInk.highlightPHP(phpCode)
```

### Creating Custom Languages

```swift
// Define custom token patterns
let sqlPatterns: [TokenPattern] = [
    try! TokenPattern(pattern: #"--.*$"#, tokenType: .lineComment, priority: 100),
    try! TokenPattern(pattern: #"\b(SELECT|FROM|WHERE|INSERT|UPDATE|DELETE)\b"#, tokenType: .sqlKeyword, priority: 70),
    // Add more patterns...
]

// Create a custom language
let sqlLanguage = RegexLanguage(
    identifier: "sql",
    fileExtensions: ["sql"],
    tokenPatterns: sqlPatterns
)

// Use with custom syntax highlighter
let customSyntaxInk = UniversalSyntaxInk(languages: [sqlLanguage])
let highlighted = customSyntaxInk.highlight(sqlCode, language: "sql")
```

## Legacy Swift Support

For Swift-specific syntax highlighting with SwiftSyntax integration:

```swift
import SwiftSyntaxInk

let sourceCode = """
let person = Person(name: "matsuji")
try! await person.say("Hi, SyntaxInk can highlight Swift code!")
"""

let syntaxHighlighter = SwiftSyntaxHighlighter(theme: .default)
let attributedString = syntaxHighlighter.highlight(sourceCode)
```

### Swift Custom Themes

```swift
let theme = SwiftTheme { kind in
    var base = SyntaxStyle(
        font: .system(size: 16, weight: .medium, design: .monospaced),
        color: SyntaxColor(red: 255, green: 255, blue: 255)
    )
    switch kind {
    case .keywords:
        base.font.weight = .bold
    default: break
    }
    return base
}
```

## Installation

### Swift Package Manager

```swift
let package = Package(
    // ...
    dependencies: [
        .package(url: "https://github.com/mtj0928/SyntaxInk.git", from: "0.0.1"),
    ],
    targets: [
        .target(name: "YOUR_TARGET", dependencies: [
            .product(name: "SyntaxInk", package: "SyntaxInk"),
            .product(name: "SwiftSyntaxInk", package: "SyntaxInk") // Optional: for Swift-specific highlighting
        ])
    ]
)
```

### Xcode

1. Go to File → Add Package Dependencies
2. Enter the URL: `https://github.com/mtj0928/SyntaxInk.git`
3. Select the version and add to your project

## Performance

- **Optimized for speed**: Regex-based tokenization with priority-based matching
- **Memory efficient**: Minimal memory footprint with lazy evaluation
- **Thread-safe**: Can be used concurrently across multiple threads
- **Recommended for files up to 100KB**: For larger files, consider chunking

## Architecture

```
SyntaxInk/
├── Core/
│   ├── Language.swift          # Language protocol and universal tokens
│   ├── UniversalGrammar.swift  # Universal grammar implementation
│   ├── Theme.swift            # Theme system
│   └── DefaultThemes.swift    # Built-in themes
├── Languages/
│   ├── JavaScriptLanguage.swift
│   ├── PythonLanguage.swift
│   ├── JavaLanguage.swift
│   ├── CLanguage.swift
│   ├── HTMLCSSLanguage.swift
│   ├── JSONLanguage.swift
│   ├── MarkdownLanguage.swift
│   ├── GoLanguage.swift
│   ├── RustLanguage.swift
│   └── PHPLanguage.swift
└── SwiftSyntaxInk/            # Swift-specific highlighter
    ├── SwiftGrammar.swift
    ├── SwiftTheme.swift
    └── Rules/
```

## Contributing

We welcome contributions! Please feel free to:

1. Add support for new languages
2. Improve existing language definitions
3. Create new themes
4. Optimize performance
5. Fix bugs and improve documentation

## Requirements

- Swift 6.0+
- macOS 12+, iOS 15+, tvOS 15+, watchOS 8+, visionOS 1+

## License

[Add your license information here]

## Credits

- Built with [SwiftSyntax](https://github.com/apple/swift-syntax) for Swift language support
- Inspired by popular syntax highlighters like Prism.js and highlight.js
- Theme colors inspired by Xcode's default themes