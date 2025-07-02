//
//  GMarkStringProcessor.swift
//  GMarkdown
//
//  Created by GIKI on 2024/7/25.
//

import Foundation

/// Utility class for safe string processing operations
public class GMarkStringProcessor {
    
    /// Safely replace occurrences of a target string with a replacement
    /// - Parameters:
    ///   - string: The original string
    ///   - target: The string to replace
    ///   - replacement: The replacement string
    /// - Returns: The processed string
    public static func replaceOccurrences(in string: String, target: String, replacement: String) -> String {
        return string.replacingOccurrences(of: target, with: replacement)
    }
    
    /// Process regex matches in reverse order to maintain string indices
    /// - Parameters:
    ///   - string: The original string
    ///   - pattern: The regex pattern
    ///   - processor: Closure that processes each match
    /// - Returns: The processed string
    public static func processMatches(
        in string: String,
        pattern: String,
        options: NSRegularExpression.Options = [],
        processor: (NSTextCheckingResult, String) -> String?
    ) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return string
        }
        
        var result = string
        let nsString = result as NSString
        let range = NSRange(location: 0, length: nsString.length)
        let matches = regex.matches(in: result, options: [], range: range).reversed()
        
        for match in matches {
            let matchRange = match.range
            let matchedString = nsString.substring(with: matchRange)
            
            if let replacement = processor(match, matchedString) {
                result = (result as NSString).replacingCharacters(in: matchRange, with: replacement)
            }
        }
        
        return result
    }
    
    /// Check if a string contains multiple lines
    /// - Parameter string: The string to check
    /// - Returns: True if the string contains newlines
    public static func isMultiline(_ string: String) -> Bool {
        return string.contains("\n") || string.contains("\r")
    }
    
    /// Get the line count of a string
    /// - Parameter string: The string to analyze
    /// - Returns: Number of lines
    public static func lineCount(of string: String) -> Int {
        return string.components(separatedBy: .newlines).count
    }
}
