//
//  GMarkLaTexRender.swift
//  GMarkdown
//
//  Created by 巩柯 on 2025/7/3.
//

import Foundation
import Markdown
import MPITextKit
import SwiftMath
import UIKit

/// 用于渲染 LaTeX 公式的专用类
///
/// 使用示例：
/// ```swift
/// // 智能渲染（推荐）- 内部会自动选择最佳渲染策略
/// let result = GMarkLaTexRender.renderLatexSmart(from: "x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}", style: style)
///
/// // 手动指定渲染方法
/// let result = GMarkLaTexRender.renderLatex(from: text, style: style, method: .fast)
///
/// // 便捷的图片渲染
/// let result = GMarkLaTexRender.renderLatexImage("E = mc^2", fontSize: 20, textColor: .black)
/// ```
public class GMarkLaTexRender {
    
    // MARK: - Render Options
    
    public enum RenderMethod {
        case fast        // 使用 SwiftMath 快速渲染
        case svgFallback // 使用 SVG 转换器作为后备方案
    }
    
    public struct RenderResult {
        public let image: UIImage?
        public let size: CGSize
        public let success: Bool
        public let error: Error?
        
        public init(image: UIImage?, size: CGSize, success: Bool, error: Error? = nil) {
            self.image = image
            self.size = size
            self.success = success
            self.error = error
        }
    }
    
    // MARK: - Public Methods
    
    /// 从 Markup 渲染 LaTeX 图片
    /// - Parameters:
    ///   - markup: Paragraph markup 包含 LaTeX 内容
    ///   - style: 渲染样式
    ///   - method: 渲染方法，默认为快速渲染
    /// - Returns: 渲染结果
    public static func renderLatex(from markup: Paragraph,
                                   style: Style,
                                   method: RenderMethod = .fast) -> RenderResult {
        var visitor = GMarkupStringifier()
        let text = visitor.visit(markup)
        let trimmedText = trimBrackets(from: text)
        
        return renderLatex(from: trimmedText, style: style, method: method)
    }
    
    /// 从文本渲染 LaTeX 图片
    /// - Parameters:
    ///   - text: LaTeX 文本内容
    ///   - style: 渲染样式
    ///   - method: 渲染方法，默认为快速渲染
    /// - Returns: 渲染结果
    public static func renderLatex(from text: String,
                                   style: Style,
                                   method: RenderMethod = .fast) -> RenderResult {
        let trimmedText = trimBrackets(from: text)
        
        // 检查缓存
        if let cachedImage = GMarkCachedManager.shared.getLatexCache(for: trimmedText) {
            return RenderResult(
                image: cachedImage,
                size: cachedImage.size,
                success: true
            )
        }
        
        switch method {
        case .fast:
            let result = renderWithSwiftMath(trimmedText, style: style)
            if result.success {
                return result
            } else {
                // 快速渲染失败，尝试 SVG 后备方案
                return renderWithSVG(trimmedText, style: style)
            }
        case .svgFallback:
            return renderWithSVG(trimmedText, style: style)
        }
    }
    
    /// 智能渲染 LaTeX 图片（推荐使用）
    /// 内部会自动选择最佳的渲染策略，外部无需关心具体实现
    /// - Parameters:
    ///   - markup: Paragraph markup 包含 LaTeX 内容
    ///   - style: 渲染样式
    /// - Returns: 渲染结果
    public static func renderLatexSmart(from markup: Paragraph, style: Style) -> RenderResult {
        var visitor = GMarkupStringifier()
        let text = visitor.visit(markup)
        return renderLatexSmart(from: text, style: style)
    }
    
    /// 智能渲染 LaTeX 图片（推荐使用）
    /// 内部会自动选择最佳的渲染策略，外部无需关心具体实现
    /// - Parameters:
    ///   - text: LaTeX 文本内容
    ///   - style: 渲染样式
    /// - Returns: 渲染结果
    public static func renderLatexSmart(from text: String, style: Style) -> RenderResult {
        let trimmedText = trimBrackets(from: text)
        
        // 检查缓存
        if let cachedImage = GMarkCachedManager.shared.getLatexCache(for: trimmedText) {
            return RenderResult(
                image: cachedImage,
                size: cachedImage.size,
                success: true
            )
        }
        
        // 智能选择渲染方法
        let method = selectOptimalRenderMethod(for: trimmedText, style: style)
        
        switch method {
        case .fast:
            let result = renderWithSwiftMath(trimmedText, style: style)
            if result.success {
                return result
            } else {
                // 快速渲染失败，自动切换到 SVG
                
#if DEBUG
                print("SwiftMath 渲染失败，自动切换到 SVG 渲染")
#endif
                return renderWithSVG(trimmedText, style: style)
            }
        case .svgFallback:
            return renderWithSVG(trimmedText, style: style)
        }
    }
    
    
    // MARK: - Smart Rendering Strategy
    
    /// 根据 LaTeX 内容和样式选择最优的渲染方法
    private static func selectOptimalRenderMethod(for text: String, style: Style) -> RenderMethod {
        // 复杂公式的特征检测
        let complexFeatures = [
            "\\begin{", "\\end{",           // 环境语法（矩阵、对齐等）
            "\\matrix", "\\pmatrix",        // 矩阵
            "\\cases",                      // 分段函数
            "\\align", "\\eqnarray",        // 对齐环境
            "\\stackrel", "\\overset",      // 上标注
            "\\underset", "\\underbrace",   // 下标注
            "\\xymatrix",                   // xy-pic图形
            "\\tikz", "\\begin{tikzpicture}" // TikZ图形
        ]
        
        // 检查是否包含复杂特征
        let hasComplexFeatures = complexFeatures.contains { feature in
            text.contains(feature)
        }
        
        // 检查公式长度
        let isLongFormula = text.count > 100
        
        // 检查特殊字符密度
        let specialCharCount = text.filter { "{}\\^_".contains($0) }.count
        let specialCharDensity = Double(specialCharCount) / Double(max(text.count, 1))
        
        // 决策逻辑
        let selectedMethod: RenderMethod
        if hasComplexFeatures {
            // 包含复杂特征，优先使用 SVG
            selectedMethod = .svgFallback
#if DEBUG
            print("LaTeX 智能渲染：检测到复杂特征，选择 SVG 渲染")
#endif
        } else if isLongFormula && specialCharDensity > 0.3 {
            // 长公式且特殊字符密度高，使用 SVG
            selectedMethod = .svgFallback
#if DEBUG
            print("LaTeX 智能渲染：长公式且复杂度高，选择 SVG 渲染")
#endif
        } else {
            // 简单公式，使用快速渲染
            selectedMethod = .fast
#if DEBUG
            print("LaTeX 智能渲染：简单公式，选择 SwiftMath 快速渲染")
#endif
        }
        
        return selectedMethod
    }
    
    /// 渲染 LaTeX 文本为图片（便捷方法）
    /// - Parameters:
    ///   - latexText: 已经处理过的 LaTeX 文本
    ///   - fontSize: 字体大小
    ///   - textColor: 文本颜色
    ///   - preferSVG: 是否优先使用 SVG 渲染
    /// - Returns: 渲染结果
    public static func renderLatexImage(
        _ latexText: String,
        fontSize: CGFloat = 16,
        textColor: UIColor = .black,
        preferSVG: Bool = false
    ) -> RenderResult {
        let trimmedText = trimBrackets(from: latexText)
        
        // 检查缓存
        if let cachedImage = GMarkCachedManager.shared.getLatexCache(for: trimmedText) {
            return RenderResult(
                image: cachedImage,
                size: cachedImage.size,
                success: true
            )
        }
        
        if preferSVG {
            return renderWithSVGOnly(trimmedText)
        } else {
            return renderWithSwiftMathOnly(trimmedText, fontSize: fontSize, textColor: textColor)
        }
    }
    
    // MARK: - Private Methods
    
    /// 使用 SwiftMath 进行快速渲染
    private static func renderWithSwiftMath(_ text: String, style: Style) -> RenderResult {
        var mathImage = MathImage(
            latex: text,
            fontSize: style.fonts.current.pointSize,
            textColor: style.colors.current
        )
        mathImage.font = MathFont.xitsFont
        
        let (error, image, _) = mathImage.asImage()
        
        if let image = image {
            // 缓存结果
            GMarkCachedManager.shared.setLatexCache(image, for: text)
            return RenderResult(
                image: image,
                size: image.size,
                success: true
            )
        } else {
            return RenderResult(
                image: nil,
                size: .zero,
                success: false,
                error: error
            )
        }
    }
    
    /// 使用 SVG 转换器进行渲染
    private static func renderWithSVG(_ text: String, style: Style) -> RenderResult {
        do {
            let converter = try GMarkLaTexToSVGConverter()
            let svgResult = try converter.convert(text)
            
#if DEBUG
            print("SVG 渲染结果: \(svgResult)")
#endif
            
            if let svgData = svgResult.data(using: .utf8) {
                let svgRenderer = GMarkSVGRender.shared
                if let image = svgRenderer.renderLaTeXSVG(data: svgData) {
                    // 缓存结果
                    GMarkCachedManager.shared.setLatexCache(image, for: text)
                    return RenderResult(
                        image: image,
                        size: image.size,
                        success: true
                    )
                }
            }
            
            return RenderResult(
                image: nil,
                size: .zero,
                success: false,
                error: LaTexRenderError.svgRenderFailed
            )
            
        } catch {
            return RenderResult(
                image: nil,
                size: .zero,
                success: false,
                error: error
            )
        }
    }
    
    /// 仅使用 SwiftMath 进行渲染（便捷方法）
    private static func renderWithSwiftMathOnly(_ text: String, fontSize: CGFloat, textColor: UIColor) -> RenderResult {
        var mathImage = MathImage(
            latex: text,
            fontSize: fontSize,
            textColor: textColor
        )
        mathImage.font = MathFont.xitsFont
        
        let (error, image, _) = mathImage.asImage()
        
        if let image = image {
            // 缓存结果
            GMarkCachedManager.shared.setLatexCache(image, for: text)
            return RenderResult(
                image: image,
                size: image.size,
                success: true
            )
        } else {
            return RenderResult(
                image: nil,
                size: .zero,
                success: false,
                error: error
            )
        }
    }
    
    /// 仅使用 SVG 进行渲染（便捷方法）
    private static func renderWithSVGOnly(_ text: String) -> RenderResult {
        do {
            let converter = try GMarkLaTexToSVGConverter()
            let svgResult = try converter.convert(text)
            
            if let svgData = svgResult.data(using: .utf8) {
                let svgRenderer = GMarkSVGRender.shared
                if let image = svgRenderer.renderLaTeXSVG(data: svgData) {
                    // 缓存结果
                    GMarkCachedManager.shared.setLatexCache(image, for: text)
                    return RenderResult(
                        image: image,
                        size: image.size,
                        success: true
                    )
                }
            }
            
            return RenderResult(
                image: nil,
                size: .zero,
                success: false,
                error: LaTexRenderError.svgRenderFailed
            )
            
        } catch {
            return RenderResult(
                image: nil,
                size: .zero,
                success: false,
                error: error
            )
        }
    }
    
    /// 去除 LaTeX 文本中的包装符号
    public static func trimBrackets(from string: String) -> String {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 检查并去掉方括号
        if trimmedString.hasPrefix("[") && trimmedString.hasSuffix("]") {
            return String(trimmedString.dropFirst().dropLast())
        }
        
        // 检查并去掉 $$ 符号
        if trimmedString.hasPrefix("$$") && trimmedString.hasSuffix("$$") {
            return String(trimmedString.dropFirst(2).dropLast(2))
        }
        
        // 检查并去掉单个 $ 符号
        if trimmedString.hasPrefix("$") && trimmedString.hasSuffix("$") {
            return String(trimmedString.dropFirst().dropLast())
        }
        
        return trimmedString
    }
    
}

// MARK: - Error Types

public enum LaTexRenderError: Error, LocalizedError {
    case svgConverterInitFailed
    case svgRenderFailed
    case invalidLatexText
    
    public var errorDescription: String? {
        switch self {
        case .svgConverterInitFailed:
            return "SVG 转换器初始化失败"
        case .svgRenderFailed:
            return "SVG 渲染失败"
        case .invalidLatexText:
            return "无效的 LaTeX 文本"
        }
    }
}
