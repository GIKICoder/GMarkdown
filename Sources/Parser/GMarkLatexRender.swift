//
//  GMarkLatexRender.swift
//  GMarkdown
//
//  Created by GIKI on 2025/3/15.
//

import UIKit
import MathJaxSwift

class GMarkLatexRender {
  // A reference to our MathJax instance
  private var mathjax: MathJax
  
  // The TeX input processor options - load all packages.
  private let inputOptions = TeXInputProcessorOptions(loadPackages: TeXInputProcessorOptions.Packages.all)
  
  // The SVG output processor options - align our display left.
  private let outputOptions = SVGOutputProcessorOptions(displayAlign: SVGOutputProcessorOptions.DisplayAlignments.left)
  
  // The conversion options - use block rendering.
  private let convOptions = ConversionOptions(display: true)
  
  init() throws {
    // We only want to convert to SVG
    mathjax = try MathJax(preferredOutputFormat: .svg)
  }
  
  /// Converts the TeX input to SVG.
  ///
  /// - Parameter texInput: The input string.
  /// - Returns: SVG file data.
  func convert(_ texInput: String) async throws -> String {
    return try await mathjax.tex2svg(
      texInput,
      conversionOptions: convOptions,
      inputOptions: inputOptions,
      outputOptions: outputOptions)
  }
}
