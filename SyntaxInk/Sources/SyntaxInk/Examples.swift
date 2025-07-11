import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Example usage of the Universal Syntax Highlighter
public struct SyntaxHighlightingExamples {
    
    /// Basic usage example
    public static func basicExample() {
        let syntaxInk = UniversalSyntaxInk()
        
        // Highlight JavaScript code
        let jsCode = """
        function greet(name) {
            console.log(`Hello, ${name}!`);
            return true;
        }
        """
        
        if syntaxInk.highlightJavaScript(jsCode, theme: DefaultThemes.light).length > 0 {
            print("JavaScript code highlighted successfully!")
            // Use the highlighted NSAttributedString in your UI
        }
    }
    
    /// File-based language detection example
    public static func fileDetectionExample() {
        let syntaxInk = UniversalSyntaxInk()
        
        let pythonCode = """
        def fibonacci(n):
            if n <= 1:
                return n
            return fibonacci(n-1) + fibonacci(n-2)
        
        print(fibonacci(10))
        """
        
        // Automatically detect language from filename
        if syntaxInk.highlight(pythonCode, filename: "example.py", theme: DefaultThemes.dark).length > 0 {
            print("Python code highlighted with dark theme!")
        }
    }
    
    /// Custom theme example
    public static func customThemeExample() {
        let syntaxInk = UniversalSyntaxInk()
        
        // Create a custom theme based on the light theme
        let customTheme = StandardUniversalTheme.lightTheme { builder in
            builder
                .style(for: .keyword) { style in
                    style.color = SyntaxColor(red: 0.8, green: 0.2, blue: 0.8) // Custom purple
                    style.font = .system(size: 14, weight: .bold)
                }
                .style(for: .stringLiteral) { style in
                    style.color = SyntaxColor(red: 0.0, green: 0.6, blue: 0.0) // Custom green
                }
        }
        
        let javaCode = """
        public class HelloWorld {
            public static void main(String[] args) {
                System.out.println("Hello, World!");
            }
        }
        """
        
        if syntaxInk.highlightJava(javaCode, theme: customTheme).length > 0 {
            print("Java code highlighted with custom theme!")
        }
    }
    
    /// Multiple language example
    public static func multiLanguageExample() {
        let syntaxInk = UniversalSyntaxInk()
        
        let codes = [
            ("example.js", "const x = 42; console.log(x);"),
            ("example.py", "x = 42\nprint(x)"),
            ("example.java", "int x = 42; System.out.println(x);"),
            ("example.cpp", "int x = 42; std::cout << x << std::endl;"),
            ("example.go", "x := 42; fmt.Println(x)"),
            ("example.rs", "let x = 42; println!(\"{}\", x);"),
            ("example.json", "{\"x\": 42}"),
            ("example.md", "# Hello\n\nThis is **bold** text.")
        ]
        
        for (filename, code) in codes {
            if syntaxInk.highlight(code, filename: filename, theme: DefaultThemes.light).length > 0 {
                print("Successfully highlighted \(filename)")
            }
        }
    }
    
    /// UIKit/AppKit integration example
    #if canImport(UIKit)
    @available(iOS 13.0, *)
    @MainActor
    public static func uiKitExample() -> UILabel {
        let syntaxInk = UniversalSyntaxInk()
        
        let rustCode = """
        fn main() {
            let name = "World";
            println!("Hello, {}!", name);
        }
        """
        
        let highlighted = syntaxInk.highlightRust(rustCode, theme: DefaultThemes.dark)
        
        let label = UILabel()
        label.attributedText = highlighted
        label.numberOfLines = 0
        label.backgroundColor = UIColor.black
        label.layer.cornerRadius = 8
        
        return label
    }
    #elseif canImport(AppKit)
    @available(macOS 10.15, *)
    @MainActor
    public static func appKitExample() -> NSTextField {
        let syntaxInk = UniversalSyntaxInk()
        
        let rustCode = """
        fn main() {
            let name = "World";
            println!("Hello, {}!", name);
        }
        """
        
        let highlighted = syntaxInk.highlightRust(rustCode, theme: DefaultThemes.dark)
        
        let textField = NSTextField()
        textField.attributedStringValue = highlighted
        textField.isEditable = false
        textField.isBordered = false
        textField.backgroundColor = NSColor.black
        textField.layer?.cornerRadius = 8
        
        return textField
    }
    #endif
    
    /// Custom language example
    public static func customLanguageExample() {
        // Create a simple custom language for SQL
        let sqlPatterns: [TokenPattern] = [
            try! TokenPattern(pattern: #"--.*$"#, tokenType: .lineComment, priority: 100),
            try! TokenPattern(pattern: #"/\*[\s\S]*?\*/"#, tokenType: .blockComment, priority: 100),
            try! TokenPattern(pattern: #"'(?:[^'\\]|\\.)*'"#, tokenType: .stringLiteral, priority: 90),
            try! TokenPattern(pattern: #"\b(SELECT|FROM|WHERE|INSERT|UPDATE|DELETE|CREATE|DROP|ALTER|TABLE|DATABASE|INDEX|PRIMARY|KEY|FOREIGN|NOT|NULL|UNIQUE|DEFAULT|AUTO_INCREMENT|VARCHAR|INT|CHAR|TEXT|DATETIME|TIMESTAMP)\b"#, tokenType: .sqlKeyword, priority: 70),
            try! TokenPattern(pattern: #"\b(COUNT|SUM|AVG|MIN|MAX|UPPER|LOWER|SUBSTRING|CONCAT|NOW|CURDATE|CURTIME)\b"#, tokenType: .sqlFunction, priority: 68),
            try! TokenPattern(pattern: #"\b\d+\.?\d*\b"#, tokenType: .numberLiteral, priority: 60),
            try! TokenPattern(pattern: #"\b[a-zA-Z_][a-zA-Z0-9_]*\b"#, tokenType: .identifier, priority: 30),
            try! TokenPattern(pattern: #"[ \t]+"#, tokenType: .whitespace, priority: 10),
            try! TokenPattern(pattern: #"\n"#, tokenType: .newline, priority: 10)
        ]
        
        let sqlLanguage = RegexLanguage(
            identifier: "sql",
            fileExtensions: ["sql"],
            tokenPatterns: sqlPatterns
        )
        
        let customSyntaxInk = UniversalSyntaxInk(languages: [sqlLanguage])
        
        let sqlCode = """
        SELECT name, age FROM users 
        WHERE age > 21 
        ORDER BY name;
        """
        
        if customSyntaxInk.highlight(sqlCode, language: "sql", theme: DefaultThemes.light).length > 0 {
            print("Custom SQL language highlighted successfully!")
        }
    }
}

// MARK: - Usage Documentation

/**
 # Universal Syntax Highlighter Usage Guide
 
 ## Basic Usage
 
 ```swift
 let syntaxInk = UniversalSyntaxInk()
 let code = "console.log('Hello, World!');"
 let highlighted = syntaxInk.highlightJavaScript(code)
 ```
 
 ## Supported Languages
 
 - JavaScript/TypeScript (.js, .jsx, .ts, .tsx, .mjs, .cjs)
 - Python (.py, .pyw, .pyi)
 - Java (.java)
 - C/C++ (.c, .cpp, .cc, .cxx, .c++, .h, .hpp, .hxx, .h++)
 - HTML (.html, .htm, .xhtml)
 - CSS (.css, .scss, .sass, .less)
 - JSON (.json, .jsonc, .json5)
 - Markdown (.md, .markdown, .mdown, .mkdn, .mkd, .mdx)
 - Go (.go)
 - Rust (.rs)
 - PHP (.php, .php3, .php4, .php5, .phtml)
 
 ## Themes
 
 ### Built-in Themes
 - `DefaultThemes.light` - Light theme inspired by Xcode
 - `DefaultThemes.dark` - Dark theme inspired by Xcode
 
 ### Custom Themes
 ```swift
 let customTheme = StandardUniversalTheme.lightTheme { builder in
     builder
         .style(for: .keyword) { style in
             style.color = SyntaxColor(red: 1.0, green: 0.0, blue: 0.0)
             style.font = .system(size: 16, weight: .bold)
         }
 }
 ```
 
 ## Language Detection
 
 The highlighter can automatically detect languages from file extensions:
 
 ```swift
 let highlighted = syntaxInk.highlight(code, filename: "example.py")
 ```
 
 ## UIKit/AppKit Integration
 
 ```swift
 // UIKit
 let label = UILabel()
 label.attributedText = highlighted
 
 // AppKit
 let textField = NSTextField()
 textField.attributedStringValue = highlighted
 ```
 
 ## Performance Considerations
 
 - The regex-based tokenizer is optimized for moderate file sizes
 - For very large files (>100KB), consider chunking the content
 - Caching highlighted results is recommended for repeated use
 - The tokenizer is thread-safe and can be used concurrently
 
 ## Extending with New Languages
 
 ```swift
 let customLanguage = RegexLanguage(
     identifier: "mylang",
     fileExtensions: ["ml"],
     tokenPatterns: [
         try! TokenPattern(pattern: #"//.*$"#, tokenType: .lineComment, priority: 100),
         // Add more patterns...
     ]
 )
 
 let syntaxInk = UniversalSyntaxInk(languages: [customLanguage])
 ```
 */