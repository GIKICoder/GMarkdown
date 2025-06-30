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
    
    let selectedPackages = [
        TeXInputProcessorOptions.Packages.ams,          // 用于扩展数学符号和环境
        TeXInputProcessorOptions.Packages.base,         // 基础包，必要
        TeXInputProcessorOptions.Packages.bbox,         // 调整边框和背景色
        TeXInputProcessorOptions.Packages.boldsymbol,   // 数学符号加粗
        TeXInputProcessorOptions.Packages.color,        // 文本和公式颜色
        TeXInputProcessorOptions.Packages.newcommand,   // 定义新的命令和宏
        TeXInputProcessorOptions.Packages.noerrors,     // 出错时不显示错误信息
        TeXInputProcessorOptions.Packages.noundefined,  // 处理未定义命令
        TeXInputProcessorOptions.Packages.unicode,      // 支持 Unicode 字符
        TeXInputProcessorOptions.Packages.mathtools     // amsmath 的扩展，提供更多工具
    ];
    
    // The TeX input processor options - load all packages.
    private let inputOptions = TeXInputProcessorOptions(loadPackages:[
        TeXInputProcessorOptions.Packages.ams,          // 用于扩展数学符号和环境
        TeXInputProcessorOptions.Packages.base,         // 基础包，必要
        TeXInputProcessorOptions.Packages.bbox,         // 调整边框和背景色
        TeXInputProcessorOptions.Packages.boldsymbol,   // 数学符号加粗
        TeXInputProcessorOptions.Packages.color,        // 文本和公式颜色
        TeXInputProcessorOptions.Packages.newcommand,   // 定义新的命令和宏
        TeXInputProcessorOptions.Packages.noerrors,     // 出错时不显示错误信息
        TeXInputProcessorOptions.Packages.noundefined,  // 处理未定义命令
        TeXInputProcessorOptions.Packages.unicode,      // 支持 Unicode 字符
        TeXInputProcessorOptions.Packages.mathtools     // amsmath 的扩展，提供更多工具
    ], processEscapes: true)
    

    
    // The conversion options - use block rendering and increase container dimensions.
    private let convOptions: ConversionOptions = ConversionOptions(
        display: true,            // Enable block rendering for better layout and line breaks
        em: 100,
        ex: 1,
        containerWidth: 300,      // Increased container width for larger SVG
        lineWidth: 300,           // Increased line width to match container
        scale: 3.0
    )
    
    let outputOptionsv2 = SVGOutputProcessorOptions(
        scale: 1.0,                 // Adjust scale if necessary
        minScale: 1.0,
        mtextInheritFont: true,
        merrorInheritFont: true,
        unknownFamily: "serif",
        mathmlSpacing: true,
        skipAttributes: [:],
        exFactor: 1.0,
        displayAlign: "center",
        displayIndent: 0.0
    )
    
    let conversionOptions = ConversionOptions(
        display: true,
        em: 32,
        ex: 16,
        containerWidth: 600, // Set container width to 600 units
        lineWidth: 16,       // Set line width to match container width
        scale: 3.0            // Adjust scale as needed
    )
    
    let documentOptions = DocumentOptions(
        skipHtmlTags: DocumentOptions.defaultSkipHtmlTags,
        includeHtmlTags: DocumentOptions.defaultIncludedHtmlTags,
        enableEnrichment: true,
        enableComplexity: true,
        makeCollapsible: false, // Disable collapsible sections if not needed
        identifyCollapsible: false,
        enableExplorer: true,
        enableAssistiveMml: false,
        enableMenu: true,
        annotationTypes: DocumentOptions.defaultAnnotationTypes,
        a11y: DocumentOptions.defaultA11Y,
        sre: DocumentOptions.defaultSREOptions,
        menuOptions: DocumentOptions.defaultMenuOptions,
        safeOptions: DocumentOptions.defaultSafeOptions,
        enrichError: nil,
        compileError: nil,
        typesetError: nil
    )
    
    init() throws {
        // We only want to convert to SVG
        mathjax = try MathJax(preferredOutputFormat: .svg)
    }
    
    /// Converts the TeX input to SVG.
    ///
    /// - Parameter texInput: The input string.
    /// - Returns: SVG file data as a String.
    func convert(_ texInput: String) throws -> String {
        return try mathjax.tex2svg(texInput,
                                   css: false,
                                   assistiveMml: false,
                                   container: false,
                                   styles: false,
                                   conversionOptions: conversionOptions,
                                   documentOptions: documentOptions,
                                   inputOptions: inputOptions,
                                   outputOptions: outputOptionsv2)
    }
}
