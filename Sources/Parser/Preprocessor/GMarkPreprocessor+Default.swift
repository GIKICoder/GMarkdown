//
//  GMarkPreprocessor+Default.swift
//  GMarkdown
//
//  Created by GIKI on 2024/7/25.
//

import Foundation

extension GMarkPreprocessor {
    
    /// Setup default preprocessors with all implementations
    public func setupDefaultProcessors() {
        addProcessor(LaTeXPreprocessor())
        addProcessor(CodeBlockPreprocessor())
        addProcessor(ImagePreprocessor())
    }
    
    /// Create a preprocessor with default setup
    public static func createDefault() -> GMarkPreprocessor {
        let preprocessor = GMarkPreprocessor()
        preprocessor.setupDefaultProcessors()
        return preprocessor
    }
}
