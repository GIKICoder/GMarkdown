import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Default theme configurations for universal syntax highlighting
public struct DefaultThemes {
    
    /// Light theme with colors inspired by Xcode's light theme
    public static let light = StandardUniversalTheme(styleMap: [
        // Basic types
        .plainText: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0)
        ),
        .whitespace: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0)
        ),
        .newline: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0)
        ),
        
        // Comments
        .lineComment: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.42, green: 0.48, blue: 0.53) // Gray
        ),
        .blockComment: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.42, green: 0.48, blue: 0.53) // Gray
        ),
        .docComment: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.42, green: 0.48, blue: 0.53) // Gray
        ),
        
        // Literals
        .stringLiteral: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.77, green: 0.10, blue: 0.09) // Red
        ),
        .numberLiteral: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.0, blue: 0.81) // Blue
        ),
        .booleanLiteral: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.64, green: 0.08, blue: 0.64) // Purple
        ),
        .nullLiteral: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.64, green: 0.08, blue: 0.64) // Purple
        ),
        .characterLiteral: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.77, green: 0.10, blue: 0.09) // Red
        ),
        .regexLiteral: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.77, green: 0.10, blue: 0.09) // Red
        ),
        
        // Keywords
        .keyword: SyntaxStyle(
            font: .system(size: 14, weight: .bold),
            color: SyntaxColor(red: 0.64, green: 0.08, blue: 0.64) // Purple
        ),
        .controlKeyword: SyntaxStyle(
            font: .system(size: 14, weight: .bold),
            color: SyntaxColor(red: 0.64, green: 0.08, blue: 0.64) // Purple
        ),
        .declarationKeyword: SyntaxStyle(
            font: .system(size: 14, weight: .bold),
            color: SyntaxColor(red: 0.64, green: 0.08, blue: 0.64) // Purple
        ),
        .modifier: SyntaxStyle(
            font: .system(size: 14, weight: .bold),
            color: SyntaxColor(red: 0.64, green: 0.08, blue: 0.64) // Purple
        ),
        .`operator`: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0) // Black
        ),
        
        // Identifiers
        .identifier: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0) // Black
        ),
        .functionName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.24, green: 0.40, blue: 0.72) // Blue
        ),
        .methodName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.24, green: 0.40, blue: 0.72) // Blue
        ),
        .propertyName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.63, blue: 0.95) // Light Blue
        ),
        .variableName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.63, blue: 0.95) // Light Blue
        ),
        .parameterName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.63, blue: 0.95) // Light Blue
        ),
        .typeName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.63, blue: 0.95) // Light Blue
        ),
        .className: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.63, blue: 0.95) // Light Blue
        ),
        .interfaceName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.63, blue: 0.95) // Light Blue
        ),
        .enumName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.63, blue: 0.95) // Light Blue
        ),
        .structName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.63, blue: 0.95) // Light Blue
        ),
        .protocolName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.63, blue: 0.95) // Light Blue
        ),
        .namespaceName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.63, blue: 0.95) // Light Blue
        ),
        .moduleName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.63, blue: 0.95) // Light Blue
        ),
        .packageName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.63, blue: 0.95) // Light Blue
        ),
        
        // Symbols
        .punctuation: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0) // Black
        ),
        .bracket: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0) // Black
        ),
        .brace: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0) // Black
        ),
        .parenthesis: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0) // Black
        ),
        .delimiter: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0) // Black
        ),
        .semicolon: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0) // Black
        ),
        .comma: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0) // Black
        ),
        .dot: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0) // Black
        ),
        .colon: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0) // Black
        ),
        
        // Preprocessor/Directives
        .preprocessor: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.64, green: 0.08, blue: 0.64) // Purple
        ),
        .directive: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.64, green: 0.08, blue: 0.64) // Purple
        ),
        .annotation: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.64, green: 0.08, blue: 0.64) // Purple
        ),
        .attribute: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.64, green: 0.08, blue: 0.64) // Purple
        ),
        .decorator: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.64, green: 0.08, blue: 0.64) // Purple
        ),
        
        // Markup
        .markupHeading: SyntaxStyle(
            font: .system(size: 16, weight: .bold),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0) // Black
        ),
        .markupBold: SyntaxStyle(
            font: .system(size: 14, weight: .bold),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0) // Black
        ),
        .markupItalic: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0) // Black
        ),
        .markupCode: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.77, green: 0.10, blue: 0.09) // Red
        ),
        .markupLink: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.24, green: 0.40, blue: 0.72) // Blue
        ),
        .markupList: SyntaxStyle(
            font: .system(size: 14, weight: .bold),
            color: SyntaxColor(red: 0.64, green: 0.08, blue: 0.64) // Purple
        ),
        .markupQuote: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.42, green: 0.48, blue: 0.53) // Gray
        ),
        .htmlTag: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.64, green: 0.08, blue: 0.64) // Purple
        ),
        .htmlAttribute: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.24, green: 0.40, blue: 0.72) // Blue
        ),
        .htmlAttributeValue: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.77, green: 0.10, blue: 0.09) // Red
        ),
        
        // Language-specific
        .generic: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.63, blue: 0.95) // Light Blue
        ),
        .template: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.63, blue: 0.95) // Light Blue
        ),
        .macro: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.64, green: 0.08, blue: 0.64) // Purple
        ),
        .label: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0) // Black
        ),
        .constant: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.63, blue: 0.95) // Light Blue
        ),
        .builtin: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.64, green: 0.08, blue: 0.64) // Purple
        ),
        .error: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 0.0, blue: 0.0) // Red
        ),
        .warning: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 0.5, blue: 0.0) // Orange
        ),
        
        // JSON specific
        .jsonKey: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.24, green: 0.40, blue: 0.72) // Blue
        ),
        .jsonValue: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.77, green: 0.10, blue: 0.09) // Red
        ),
        
        // CSS specific
        .cssSelector: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.24, green: 0.40, blue: 0.72) // Blue
        ),
        .cssProperty: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.63, blue: 0.95) // Light Blue
        ),
        .cssValue: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.77, green: 0.10, blue: 0.09) // Red
        ),
        .cssUnit: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.0, blue: 0.81) // Blue
        ),
        
        // SQL specific
        .sqlKeyword: SyntaxStyle(
            font: .system(size: 14, weight: .bold),
            color: SyntaxColor(red: 0.64, green: 0.08, blue: 0.64) // Purple
        ),
        .sqlFunction: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.24, green: 0.40, blue: 0.72) // Blue
        ),
        .sqlTable: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.63, blue: 0.95) // Light Blue
        ),
        .sqlColumn: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.11, green: 0.63, blue: 0.95) // Light Blue
        ),
        .fallbackText: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.0, green: 0.0, blue: 0.0) // Black
        )
    ], identifier: "light")
    
    /// Dark theme with colors inspired by Xcode's dark theme
    public static let dark = StandardUniversalTheme(styleMap: [
        // Basic types
        .plainText: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        ),
        .whitespace: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        ),
        .newline: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        ),
        
        // Comments
        .lineComment: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.42, green: 0.48, blue: 0.53) // Gray
        ),
        .blockComment: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.42, green: 0.48, blue: 0.53) // Gray
        ),
        .docComment: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.42, green: 0.48, blue: 0.53) // Gray
        ),
        
        // Literals
        .stringLiteral: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 0.32, blue: 0.32) // Light Red
        ),
        .numberLiteral: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.64, green: 0.76, blue: 1.0) // Light Blue
        ),
        .booleanLiteral: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.83, green: 0.49, blue: 0.83) // Light Purple
        ),
        .nullLiteral: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.83, green: 0.49, blue: 0.83) // Light Purple
        ),
        .characterLiteral: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 0.32, blue: 0.32) // Light Red
        ),
        .regexLiteral: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 0.32, blue: 0.32) // Light Red
        ),
        
        // Keywords
        .keyword: SyntaxStyle(
            font: .system(size: 14, weight: .bold),
            color: SyntaxColor(red: 0.83, green: 0.49, blue: 0.83) // Light Purple
        ),
        .controlKeyword: SyntaxStyle(
            font: .system(size: 14, weight: .bold),
            color: SyntaxColor(red: 0.83, green: 0.49, blue: 0.83) // Light Purple
        ),
        .declarationKeyword: SyntaxStyle(
            font: .system(size: 14, weight: .bold),
            color: SyntaxColor(red: 0.83, green: 0.49, blue: 0.83) // Light Purple
        ),
        .modifier: SyntaxStyle(
            font: .system(size: 14, weight: .bold),
            color: SyntaxColor(red: 0.83, green: 0.49, blue: 0.83) // Light Purple
        ),
        .`operator`: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        ),
        
        // Identifiers
        .identifier: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        ),
        .functionName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.55, green: 0.87, blue: 0.98) // Light Cyan
        ),
        .methodName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.55, green: 0.87, blue: 0.98) // Light Cyan
        ),
        .propertyName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.36, green: 0.75, blue: 0.95) // Cyan
        ),
        .variableName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.36, green: 0.75, blue: 0.95) // Cyan
        ),
        .parameterName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.36, green: 0.75, blue: 0.95) // Cyan
        ),
        .typeName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.36, green: 0.75, blue: 0.95) // Cyan
        ),
        .className: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.36, green: 0.75, blue: 0.95) // Cyan
        ),
        .interfaceName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.36, green: 0.75, blue: 0.95) // Cyan
        ),
        .enumName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.36, green: 0.75, blue: 0.95) // Cyan
        ),
        .structName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.36, green: 0.75, blue: 0.95) // Cyan
        ),
        .protocolName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.36, green: 0.75, blue: 0.95) // Cyan
        ),
        .namespaceName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.36, green: 0.75, blue: 0.95) // Cyan
        ),
        .moduleName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.36, green: 0.75, blue: 0.95) // Cyan
        ),
        .packageName: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.36, green: 0.75, blue: 0.95) // Cyan
        ),
        
        // Symbols
        .punctuation: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        ),
        .bracket: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        ),
        .brace: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        ),
        .parenthesis: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        ),
        .delimiter: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        ),
        .semicolon: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        ),
        .comma: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        ),
        .dot: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        ),
        .colon: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        ),
        
        // Preprocessor/Directives
        .preprocessor: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.83, green: 0.49, blue: 0.83) // Light Purple
        ),
        .directive: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.83, green: 0.49, blue: 0.83) // Light Purple
        ),
        .annotation: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.83, green: 0.49, blue: 0.83) // Light Purple
        ),
        .attribute: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.83, green: 0.49, blue: 0.83) // Light Purple
        ),
        .decorator: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.83, green: 0.49, blue: 0.83) // Light Purple
        ),
        
        // Markup
        .markupHeading: SyntaxStyle(
            font: .system(size: 16, weight: .bold),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        ),
        .markupBold: SyntaxStyle(
            font: .system(size: 14, weight: .bold),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        ),
        .markupItalic: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        ),
        .markupCode: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 0.32, blue: 0.32) // Light Red
        ),
        .markupLink: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.55, green: 0.87, blue: 0.98) // Light Cyan
        ),
        .markupList: SyntaxStyle(
            font: .system(size: 14, weight: .bold),
            color: SyntaxColor(red: 0.83, green: 0.49, blue: 0.83) // Light Purple
        ),
        .markupQuote: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.42, green: 0.48, blue: 0.53) // Gray
        ),
        .htmlTag: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.83, green: 0.49, blue: 0.83) // Light Purple
        ),
        .htmlAttribute: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.55, green: 0.87, blue: 0.98) // Light Cyan
        ),
        .htmlAttributeValue: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 0.32, blue: 0.32) // Light Red
        ),
        
        // Language-specific
        .generic: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.36, green: 0.75, blue: 0.95) // Cyan
        ),
        .template: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.36, green: 0.75, blue: 0.95) // Cyan
        ),
        .macro: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.83, green: 0.49, blue: 0.83) // Light Purple
        ),
        .label: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        ),
        .constant: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.36, green: 0.75, blue: 0.95) // Cyan
        ),
        .builtin: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.83, green: 0.49, blue: 0.83) // Light Purple
        ),
        .error: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 0.4, blue: 0.4) // Light Red
        ),
        .warning: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 0.7, blue: 0.0) // Light Orange
        ),
        
        // JSON specific
        .jsonKey: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.55, green: 0.87, blue: 0.98) // Light Cyan
        ),
        .jsonValue: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 0.32, blue: 0.32) // Light Red
        ),
        
        // CSS specific
        .cssSelector: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.55, green: 0.87, blue: 0.98) // Light Cyan
        ),
        .cssProperty: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.36, green: 0.75, blue: 0.95) // Cyan
        ),
        .cssValue: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 0.32, blue: 0.32) // Light Red
        ),
        .cssUnit: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.64, green: 0.76, blue: 1.0) // Light Blue
        ),
        
        // SQL specific
        .sqlKeyword: SyntaxStyle(
            font: .system(size: 14, weight: .bold),
            color: SyntaxColor(red: 0.83, green: 0.49, blue: 0.83) // Light Purple
        ),
        .sqlFunction: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.55, green: 0.87, blue: 0.98) // Light Cyan
        ),
        .sqlTable: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.36, green: 0.75, blue: 0.95) // Cyan
        ),
        .sqlColumn: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0.36, green: 0.75, blue: 0.95) // Cyan
        ),
        .fallbackText: SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 1.0, green: 1.0, blue: 1.0) // White
        )
    ], identifier: "dark")
}

/// Theme builder for creating custom themes
public struct ThemeBuilder {
    private var styles: [TokenType: SyntaxStyle] = [:]
    
    public init() {}
    
    /// Set style for a specific token type
    public func style(for tokenType: TokenType, style: SyntaxStyle) -> ThemeBuilder {
        var builder = self
        builder.styles[tokenType] = style
        return builder
    }
    
    /// Set style for a specific token type using closure
    public func style(for tokenType: TokenType, _ configure: (inout SyntaxStyle) -> Void) -> ThemeBuilder {
        var builder = self
        var style = SyntaxStyle(
            font: .system(size: 14, weight: .regular),
            color: SyntaxColor(red: 0, green: 0, blue: 0)
        )
        configure(&style)
        builder.styles[tokenType] = style
        return builder
    }
    
    /// Build the theme
    public func build(identifier: String = UUID().uuidString) -> StandardUniversalTheme {
        return StandardUniversalTheme(styleMap: styles, identifier: identifier)
    }
}

/// Convenience extensions for creating themes
public extension StandardUniversalTheme {
    /// Create a theme based on the light theme with modifications
    static func lightTheme(modifications: (ThemeBuilder) -> ThemeBuilder) -> StandardUniversalTheme {
        var builder = ThemeBuilder()
        // Add all default light theme styles
        for tokenType in TokenType.allCases {
            builder = builder.style(for: tokenType, style: DefaultThemes.light.style(for: tokenType))
        }
        return modifications(builder).build()
    }
    
    /// Create a theme based on the dark theme with modifications
    static func darkTheme(modifications: (ThemeBuilder) -> ThemeBuilder) -> StandardUniversalTheme {
        var builder = ThemeBuilder()
        // Add all default dark theme styles
        for tokenType in TokenType.allCases {
            builder = builder.style(for: tokenType, style: DefaultThemes.dark.style(for: tokenType))
        }
        return modifications(builder).build()
    }
}