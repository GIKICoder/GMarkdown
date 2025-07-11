#if DEBUG
import SwiftUI
import SyntaxInk

// Cross-platform wrapper for NSAttributedString on iOS 13-14 and macOS 10.15-11
#if canImport(UIKit)
import UIKit
@available(iOS 13.0, *)
struct NSAttributedStringView: UIViewRepresentable {
    let attributedString: NSAttributedString
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = attributedString
    }
}
#elseif canImport(AppKit)
import AppKit
@available(macOS 10.15, *)
struct NSAttributedStringView: NSViewRepresentable {
    let attributedString: NSAttributedString
    
    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.isEditable = false
        textField.isSelectable = true
        textField.isBordered = false
        textField.backgroundColor = .clear
        textField.lineBreakMode = .byWordWrapping
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentHuggingPriority(.defaultLow, for: .vertical)
        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.attributedStringValue = attributedString
    }
}
#endif

struct Playground: View {
    var code: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let syntaxHighlighter = SwiftSyntaxHighlighter(theme: colorScheme == .light ? .default : .defaultDark)
        let attributedString = syntaxHighlighter.highlight(code)
        ScrollView {
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
                Text(AttributedString(attributedString))
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                // For iOS 13-14, use a UIViewRepresentable wrapper
                NSAttributedStringView(attributedString: attributedString)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(colorScheme == .light ? Color.xcodeBackgroundDefaultColor : .xcodeBackgroundDefaultDarkColor)
#if os(visionOS)
        .glassBackgroundEffect()
#endif
    }
}

let sourceCode = """
import Observation

struct Foo {}
enum Bar {}
actor Baz {}

@Observable
@MainActor
final class Person<T: Hashable>: Sendable, Hashable {
    var age: Int = 1234.0

    /// Creates an instance
    init(age: Int) { 
        self.age = age 
    }

#if os(iOS)
    func aaa(_ actor: isolated (any Actor)? = #isolation) {
        // do something
    }
#else 
    func aaa() async throws(FooError) {
        let foo = Foo()
        foo.doSomething(foo.number, aaa: T.aaa())
    }
#endif
}

let person = Person()
print("Name: \\(person.name)")
#expect(true)
function calculateSum(a, b) {
    return a + b;
}
"""

#Preview {
    Playground(code: sourceCode)
}


let code2 = """
class Foo { 
    typealias AAA = String
}

protocol Foo { 
    associatedtype AAAA
}

extension Foo.AAA {
    var number: Int {
        get { 10 }
        nonmutating set { }
    }
}
"""

#Preview {
    Playground(code: code2)
}

let code3 = """
protocol TP {
    static func number() -> Int
}

struct BBB {
    static let shared = BBB()
}

struct AAA<T: TP> {
    private func aaa(_ handler: @escaping @Sendable () -> Void) {
    }

    func doo(_ actor: isolated (any Actor)? = #isolation) {
        let ff = AAA()
        let _ = BBB.shared
        let number = T.number()
        if 1 == 2 {}
        #expect(1 == 1)
    }

    subscript() {}
}
"""

#Preview {
    Playground(code: code3)
}

#endif
