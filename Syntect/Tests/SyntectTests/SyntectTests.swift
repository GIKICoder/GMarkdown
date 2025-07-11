import XCTest
@testable import Syntect

final class SyntectTests: XCTestCase {
    
    func testBasicHighlighting() {
        let syntect = Syntect(syntax: "Swift", theme: "base16-ocean.dark")
        let code = "let greeting = \"Hello, World!\""
        let result = syntect.highlight(code)
        
        XCTAssertEqual(result.string, code)
        XCTAssertGreaterThan(result.length, 0)
    }
    
    func testAvailableSyntaxes() {
        let syntect = Syntect.shared
        let syntaxes = syntect.availableSyntaxes
        
        XCTAssertTrue(syntaxes.contains("Swift"))
        XCTAssertTrue(syntaxes.contains("JavaScript"))
        XCTAssertTrue(syntaxes.contains("Python"))
    }
    
    func testAvailableThemes() {
        let syntect = Syntect.shared
        let themes = syntect.availableThemes
        
        XCTAssertTrue(themes.contains("base16-ocean.dark"))
        XCTAssertTrue(themes.contains("Solarized (dark)"))
    }
    
    func testSyntaxForExtension() {
        let syntect = Syntect.shared
        
        XCTAssertEqual(syntect.syntaxForExtension("swift"), "Swift")
        XCTAssertEqual(syntect.syntaxForExtension("js"), "JavaScript")
        XCTAssertEqual(syntect.syntaxForExtension("py"), "Python")
    }
    
    func testHighlightMultipleLines() {
        let syntect = Syntect(syntax: "Swift", theme: "base16-ocean.dark")
        let lines = [
            "import Foundation",
            "let name = \"Swift\"",
            "print(\"Hello, \\(name)!\")"
        ]
        
        let results = syntect.highlightLines(lines)
        
        XCTAssertEqual(results.count, 3)
        for (index, result) in results.enumerated() {
            XCTAssertEqual(result.string, lines[index])
        }
    }
    
    func testCreateHighlighter() {
        let syntect = Syntect()
        
        syntect.createHighlighter(syntax: "JavaScript", theme: "Solarized (dark)")
        
        let code = "console.log('Hello, World!');"
        let result = syntect.highlight(code)
        
        XCTAssertEqual(result.string, code)
    }
}