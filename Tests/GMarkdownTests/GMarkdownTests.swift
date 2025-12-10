import XCTest
@testable import GMarkdown

final class GMarkdownTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
    
    // MARK: - LaTeX Preprocessor Tests
    
    func testLaTeXPreprocessorDoesNotMatchCurrencySymbols() throws {
        let preprocessor = LaTeXPreprocessor()
        
        // Test case 1: $20/月 should not be treated as LaTeX
        let input1 = "$20/月"
        let result1 = preprocessor.process(input1)
        XCTAssertEqual(result1, input1, "Currency symbols like $20/月 should not be treated as LaTeX")
        
        // Test case 2: 最低$10/月 should not be treated as LaTeX
        let input2 = "最低$10/月"
        let result2 = preprocessor.process(input2)
        XCTAssertEqual(result2, input2, "Currency symbols in text like 最低$10/月 should not be treated as LaTeX")
        
        // Test case 3: Multiple currency symbols in a sentence
        let input3 = "价格从$10到$20不等"
        let result3 = preprocessor.process(input3)
        XCTAssertEqual(result3, input3, "Multiple currency symbols should not be treated as LaTeX")
    }
    
    func testLaTeXPreprocessorMatchesActualLaTeX() throws {
        let preprocessor = LaTeXPreprocessor()
        
        // Test case 1: Inline LaTeX with actual math expression
        let input1 = "The formula is $x^2 + y^2 = z^2$ in the text"
        let result1 = preprocessor.process(input1)
        XCTAssertTrue(result1.contains("<LaTex>"), "Actual LaTeX expressions should be wrapped")
        XCTAssertTrue(result1.contains("x^2 + y^2 = z^2"), "LaTeX content should be preserved")
        
        // Test case 2: Display LaTeX with $$
        let input2 = "Display formula: $$\\int_0^1 x^2 dx$$"
        let result2 = preprocessor.process(input2)
        XCTAssertTrue(result2.contains("<LaTex>"), "Display LaTeX with $$ should be wrapped")
        
        // Test case 3: LaTeX with brackets
        let input3 = "Formula: \\[x + y = z\\]"
        let result3 = preprocessor.process(input3)
        XCTAssertTrue(result3.contains("<LaTex>"), "LaTeX with \\[...\\] should be wrapped")
    }
    
    func testLaTeXPreprocessorMixedContent() throws {
        let preprocessor = LaTeXPreprocessor()
        
        // Test mixed content from the issue
        let input = "| **收费模式** | 免费基础版 / Plus订阅 ($20/月) | **完全免费** (Web端) / API超低价 | **完全免费** | 必须付费订阅 (最低$10/月) |"
        let result = preprocessor.process(input)
        
        // Currency symbols should remain unchanged
        XCTAssertTrue(result.contains("$20/月"), "Currency $20/月 should not be modified")
        XCTAssertTrue(result.contains("$10/月"), "Currency $10/月 should not be modified")
    }
}
