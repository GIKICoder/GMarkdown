import SyntaxInk

// MARK: - Default

extension SwiftTheme {
    /// The default light Xcode theme.
    ///
    /// Use `Color.xcodeBackgroundDefaultColor` as the background color for this theme.
    public static let `default` = {
        let base = SyntaxStyle(
            font: .system(size: 16, weight: .regular, design: .monospaced),
            color: SyntaxColor(red: 0, green: 0, blue: 0)
        )
        return `default`(base)
    }()

    /// The default light Xcode theme.
    /// You can change the base style.
    ///
    /// Use `Color.xcodeBackgroundDefaultColor` as the background color for this theme.
    public static func `default`(_ base: SyntaxStyle) -> SwiftTheme {
        SwiftTheme { kind in
            var style = base
            switch kind {
            case .plainText: break
            case .keywords:
                style.color = SyntaxColor(red: 155, green: 35, blue: 147)
                style.font.weight = .semibold
            case .comments:
                style.color = SyntaxColor(red: 93, green: 108, blue: 121)
            case .documentationMarkup:
                style.font.name = "Helvetica Neue"
                style.color = SyntaxColor(red: 93, green: 108, blue: 121)
            case .string:
                style.color = SyntaxColor(red: 196, green: 26, blue: 22)
            case .numbers:
                style.color = SyntaxColor(red: 196, green: 26, blue: 22)
            case .preprocessorStatements:
                style.color = SyntaxColor(red: 100, green: 56, blue: 32)
            case .typeDeclarations:
                style.color = SyntaxColor(red: 11, green: 79, blue: 121)
            case .otherDeclarations:
                style.color = SyntaxColor(red: 15, green: 104, blue: 160)
            case .otherClassNames:
                style.color = SyntaxColor(red: 57, green: 0, blue: 160)
            case .otherFunctionAndMethodNames:
                style.color = SyntaxColor(red: 108, green: 54, blue: 169)
            case .otherTypeNames:
                style.color = SyntaxColor(red: 57, green: 0, blue: 160)
            case .otherPropertiesAndGlobals:
                style.color = SyntaxColor(red: 108, green: 54, blue: 169)
            }
            return style
        }
    }
}

// MARK: - Default Dark

extension SwiftTheme {
    /// The default dark theme in Xcode.
    ///
    /// Use `Color.xcodeBackgroundDefaultDarkColor` as the background color for this theme.
    public static let defaultDark = {
        let base = SyntaxStyle(
            font: .system(size: 16, weight: .medium, design: .monospaced),
            color: SyntaxColor(red: 255, green: 255, blue: 255)
        )
        return defaultDark(base)
    }()

    /// The default dark theme in Xcode.
    /// The base style can be changed.
    ///
    /// Use `Color.xcodeBackgroundDefaultDarkColor` as the background color for this theme.
    public static func defaultDark(_ base: SyntaxStyle) -> SwiftTheme {
        SwiftTheme { kind in
            var style = base
            switch kind {
            case .plainText: break
            case .keywords:
                style.color = SyntaxColor(red: 252, green: 95, blue: 163)
                style.font.weight = .bold
            case .comments:
                style.color = SyntaxColor(red: 108, green: 121, blue: 134)
            case .documentationMarkup:
                style.color = SyntaxColor(red: 108, green: 121, blue: 134)
                style.font.name = "Helvetica"
                style.font.weight = .regular
            case .string:
                style.color = SyntaxColor(red: 252, green: 106, blue: 93)
            case .numbers:
                style.color = SyntaxColor(red: 208, green: 191, blue: 105)
            case .preprocessorStatements:
                style.color = SyntaxColor(red: 253, green: 143, blue: 63)
            case .typeDeclarations:
                style.color = SyntaxColor(red: 93, green: 216, blue: 255)
            case .otherDeclarations:
                style.color = SyntaxColor(red: 65, green: 161, blue: 192)
            case .otherClassNames:
                style.color = SyntaxColor(red: 208, green: 168, blue: 255)
            case .otherFunctionAndMethodNames:
                style.color = SyntaxColor(red: 161, green: 103, blue: 230)
            case .otherTypeNames:
                style.color = SyntaxColor(red: 208, green: 168, blue: 255)
            case .otherPropertiesAndGlobals:
                style.color = SyntaxColor(red: 161, green: 103, blue: 230)
            }
            return style
        }
    }
}
