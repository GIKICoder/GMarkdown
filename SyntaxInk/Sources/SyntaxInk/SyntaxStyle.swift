import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// A style of the syntax.
/// This struct has font and color information for a token.
public struct SyntaxStyle: Sendable {
    /// A font for a token.
    public var font: SyntaxFont

    /// A color for a token.
    public var color: SyntaxColor

    public init(font: SyntaxFont, color: SyntaxColor) {
        self.font = font
        self.color = color
    }
}

/// A color for a token.
public struct SyntaxColor: Sendable {
    public var red: CGFloat
    public var green: CGFloat
    public var blue: CGFloat
    public var alpha: CGFloat

    public init(
        red: CGFloat,
        green: CGFloat,
        blue: CGFloat,
        alpha: CGFloat = 1.0
    ) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    /// Convert to platform-specific color
    #if canImport(UIKit)
    public var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    #elseif canImport(AppKit)
    public var nsColor: NSColor {
        return NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    #endif
}

/// A font information for a syntax.
public enum SyntaxFont: Sendable {
    /// A system font.
    case system(size: CGFloat, weight: FontWeight, design: FontDesign = .monospaced)
    /// A custom font.
    case custom(name: String, size: CGFloat, weight: FontWeight)

    public init(name: String, size: CGFloat, weight: FontWeight) {
        self = .custom(name: name, size: size, weight: weight)
    }

    /// A name of a custom font.
    /// `nil` is returned when this font is a system font.
    /// And, when `nil` is set, the font will be a monospaced system font.
    public var name: String? {
        get {
            switch self {
            case .system: nil
            case .custom(let name, _, _ ): name
            }
        }
        set {
            self = if let newValue {
                .custom(name: newValue, size: size, weight: weight)
            } else {
                .system(size: size, weight: weight, design: .monospaced)
            }
        }
    }

    /// A size of this font.
    public var size: CGFloat {
        get {
            switch self {
            case .system(let size, _, _): size
            case .custom(_, let size, _): size
            }
        }
        set {
            switch self {
            case .system(_, let weight, let design):
                self = .system(size: newValue, weight: weight, design: design)
            case .custom(let name, _, let weight):
                self = .custom(name: name, size: newValue, weight: weight)
            }
        }
    }

    /// A weight for this font.
    public var weight: FontWeight {
        get {
            switch self {
            case .system(_, let weight, _): weight
            case .custom(_, _, let weight): weight
            }
        }
        set {
            switch self {
            case .system(let size, _, let design):
                self = .system(size: size, weight: newValue, design: design)
            case .custom(let name, let size, _):
                self = .custom(name: name, size: size, weight: newValue)
            }
        }
    }
    
    /// Convert to platform-specific font
    #if canImport(UIKit)
    public var uiFont: UIFont {
        switch self {
        case .system(let size, let weight, let design):
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
                .addingAttributes([
                    .size: size,
                    .traits: [UIFontDescriptor.TraitKey.weight: weight.uiWeight]
                ])
            if design == .monospaced {
                return UIFont.monospacedSystemFont(ofSize: size, weight: weight.uiWeight)
            } else {
                return UIFont(descriptor: descriptor, size: size)
            }
        case .custom(let name, let size, _):
            return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }
    #elseif canImport(AppKit)
    public var nsFont: NSFont {
        switch self {
        case .system(let size, let weight, let design):
            if design == .monospaced {
                return NSFont.monospacedSystemFont(ofSize: size, weight: weight.nsWeight)
            } else {
                return NSFont.systemFont(ofSize: size, weight: weight.nsWeight)
            }
        case .custom(let name, let size, _):
            return NSFont(name: name, size: size) ?? NSFont.systemFont(ofSize: size)
        }
    }
    #endif
}

/// Cross-platform font weight
public enum FontWeight: Sendable {
    case ultraLight
    case thin
    case light
    case regular
    case medium
    case semibold
    case bold
    case heavy
    case black
    
    #if canImport(UIKit)
    public var uiWeight: UIFont.Weight {
        switch self {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        }
    }
    #elseif canImport(AppKit)
    public var nsWeight: NSFont.Weight {
        switch self {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        }
    }
    #endif
}

/// Cross-platform font design
public enum FontDesign: Sendable {
    case `default`
    case monospaced
    case rounded
    case serif
}

/// Extension to convert SyntaxStyle to NSAttributedString attributes
public extension SyntaxStyle {
    /// Convert to NSAttributedString attributes dictionary
    var attributes: [NSAttributedString.Key: Any] {
        var attrs: [NSAttributedString.Key: Any] = [:]
        
        #if canImport(UIKit)
        attrs[.font] = font.uiFont
        attrs[.foregroundColor] = color.uiColor
        #elseif canImport(AppKit)
        attrs[.font] = font.nsFont
        attrs[.foregroundColor] = color.nsColor
        #endif
        
        return attrs
    }
}
