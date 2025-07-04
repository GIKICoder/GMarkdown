//
//  GMarkSVGRender.swift
//  GMarkdown
//
//  Created by GIKI on 2025/7/2.
//

import Foundation
import UIKit
import CoreGraphics

class GMarkSVGRender {
    
    // MARK: - Configuration Options
    struct RenderOptions {
        var prefersBitmap: Bool = false
        var imageSize: CGSize = .zero
        var preserveAspectRatio: Bool = true
        var targetSize: CGSize = .zero
    }
    
    // MARK: - Constants
    private static let kSVGTagEnd = "</svg>"
    
    // MARK: - Function Pointers
    private static var cgSVGDocumentRetain: (@convention(c) (CGSVGDocumentRef) -> CGSVGDocumentRef)?
    private static var cgSVGDocumentRelease: (@convention(c) (CGSVGDocumentRef) -> Void)?
    private static var cgSVGDocumentCreateFromData: (@convention(c) (CFData, CFDictionary?) -> CGSVGDocumentRef?)?
    private static var cgSVGDocumentWriteToData: (@convention(c) (CGSVGDocumentRef, CFMutableData, CFDictionary?) -> Void)?
    private static var cgContextDrawSVGDocument: (@convention(c) (CGContext, CGSVGDocumentRef) -> Void)?
    private static var cgSVGDocumentGetCanvasSize: (@convention(c) (CGSVGDocumentRef) -> CGSize)?
    
    // MARK: - Selectors
    private static var imageWithCGSVGDocumentSEL: Selector?
    private static var cgSVGDocumentSEL: Selector?
    
    // MARK: - Singleton
    static let shared = GMarkSVGRender()
    
    private init() {
        Self.initialize()
    }
    
    // MARK: - Initialization
    private static func initialize() {
        // Base64 decode helper
        func base64DecodedString(_ base64String: String) -> String? {
            guard let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters),
                  let string = String(data: data, encoding: .utf8) else {
                return nil
            }
            return string
        }
        
        // Load function pointers
        if let funcName = base64DecodedString("Q0dTVkdEb2N1bWVudFJldGFpbg==") {
            cgSVGDocumentRetain = unsafeBitCast(dlsym(UnsafeMutableRawPointer(bitPattern: -2), funcName), to: (@convention(c) (CGSVGDocumentRef) -> CGSVGDocumentRef)?.self)
        }
        
        if let funcName = base64DecodedString("Q0dTVkdEb2N1bWVudFJlbGVhc2U=") {
            cgSVGDocumentRelease = unsafeBitCast(dlsym(UnsafeMutableRawPointer(bitPattern: -2), funcName), to: (@convention(c) (CGSVGDocumentRef) -> Void)?.self)
        }
        
        if let funcName = base64DecodedString("Q0dTVkdEb2N1bWVudENyZWF0ZUZyb21EYXRh") {
            cgSVGDocumentCreateFromData = unsafeBitCast(dlsym(UnsafeMutableRawPointer(bitPattern: -2), funcName), to: (@convention(c) (CFData, CFDictionary?) -> CGSVGDocumentRef?)?.self)
        }
        
        if let funcName = base64DecodedString("Q0dTVkdEb2N1bWVudFdyaXRlVG9EYXRh") {
            cgSVGDocumentWriteToData = unsafeBitCast(dlsym(UnsafeMutableRawPointer(bitPattern: -2), funcName), to: (@convention(c) (CGSVGDocumentRef, CFMutableData, CFDictionary?) -> Void)?.self)
        }
        
        if let funcName = base64DecodedString("Q0dDb250ZXh0RHJhd1NWR0RvY3VtZW50") {
            cgContextDrawSVGDocument = unsafeBitCast(dlsym(UnsafeMutableRawPointer(bitPattern: -2), funcName), to: (@convention(c) (CGContext, CGSVGDocumentRef) -> Void)?.self)
        }
        
        if let funcName = base64DecodedString("Q0dTVkdEb2N1bWVudEdldENhbnZhc1NpemU=") {
            cgSVGDocumentGetCanvasSize = unsafeBitCast(dlsym(UnsafeMutableRawPointer(bitPattern: -2), funcName), to: (@convention(c) (CGSVGDocumentRef) -> CGSize)?.self)
        }
        
        // Load selectors
        if let selectorName = base64DecodedString("X2ltYWdlV2l0aENHU1ZHRG9jdW1lbnQ6") {
            imageWithCGSVGDocumentSEL = NSSelectorFromString(selectorName)
        }
        
        if let selectorName = base64DecodedString("X0NHU1ZHRG9jdW1lbnQ=") {
            cgSVGDocumentSEL = NSSelectorFromString(selectorName)
        }
    }
    
    // MARK: - Public Methods
    func canDecodeFromData(_ data: Data) -> Bool {
        return Self.isSVGFormat(for: data)
    }
    
    func decodedImage(with data: Data, options: RenderOptions = RenderOptions()) -> UIImage? {
        guard !data.isEmpty else { return nil }
        
        let image: UIImage?
        
        if !options.prefersBitmap && Self.supportsVectorSVGImage() {
            image = createVectorSVG(with: data)
        } else {
            let targetSize = options.targetSize != .zero ? options.targetSize : options.imageSize
            image = createBitmapSVG(with: data, targetSize: targetSize, preserveAspectRatio: options.preserveAspectRatio)
        }
        
        return image
    }
    
    func encodedData(with image: UIImage) -> Data? {
        guard Self.supportsVectorSVGImage() else { return nil }
        
        let data = NSMutableData()
        
        guard let cgSVGDocumentSEL = Self.cgSVGDocumentSEL,
              image.responds(to: cgSVGDocumentSEL) else {
            return nil
        }
        
        let document = image.perform(cgSVGDocumentSEL)?.takeUnretainedValue()
        guard let svgDocument = document else { return nil }
        
        do {
            Self.cgSVGDocumentWriteToData?(unsafeBitCast(svgDocument, to: CGSVGDocumentRef.self), data, nil)
            return data.copy() as? Data
        } catch {
            return nil
        }
    }
    
    // MARK: - Private Methods
    private func createVectorSVG(with data: Data) -> UIImage? {
        guard let createFromData = Self.cgSVGDocumentCreateFromData,
              let release = Self.cgSVGDocumentRelease,
              let imageWithSVGSEL = Self.imageWithCGSVGDocumentSEL else {
            return nil
        }
        
        guard let document = createFromData(data as CFData, nil) else {
            return nil
        }
        
        defer { release(document) }
        
        // Create image using private API
        let imageClass: AnyClass = UIImage.self as AnyClass
        guard imageClass.responds(to: imageWithSVGSEL) else { return nil }
        
        let method = class_getClassMethod(imageClass, imageWithSVGSEL)
        let implementation = method_getImplementation(method!)
        
        typealias ImageCreationFunction = @convention(c) (AnyClass, Selector, CGSVGDocumentRef) -> UIImage?
        let createImage = unsafeBitCast(implementation, to: ImageCreationFunction.self)
        
        let image = createImage(imageClass, imageWithSVGSEL, document)
        
        // Test render to catch potential issues
        return testRender(image: image)
    }
    
    private func createBitmapSVG(with data: Data, targetSize: CGSize, preserveAspectRatio: Bool) -> UIImage? {
        guard let createFromData = Self.cgSVGDocumentCreateFromData,
              let getCanvasSize = Self.cgSVGDocumentGetCanvasSize,
              let drawSVGDocument = Self.cgContextDrawSVGDocument,
              let release = Self.cgSVGDocumentRelease else {
            return nil
        }
        
        guard let document = createFromData(data as CFData, nil) else {
            return nil
        }
        
        defer { release(document) }
        
        let size = getCanvasSize(document)
        guard size.width > 0 && size.height > 0 else { return nil }
        
        let (finalSize, transform) = calculateSizeAndTransform(
            originalSize: size,
            targetSize: targetSize,
            preserveAspectRatio: preserveAspectRatio
        )
        
        UIGraphicsBeginImageContextWithOptions(finalSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        // Flip coordinate system for UIKit
        context.translateBy(x: 0, y: finalSize.height)
        context.scaleBy(x: 1, y: -1)
        
        context.concatenate(transform)
        
        drawSVGDocument(context, document)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private func calculateSizeAndTransform(originalSize: CGSize, targetSize: CGSize, preserveAspectRatio: Bool) -> (CGSize, CGAffineTransform) {
        var finalSize = targetSize
        var xScale: CGFloat
        var yScale: CGFloat
        
        if targetSize.width <= 0 && targetSize.height <= 0 {
            finalSize = originalSize
            xScale = 1
            yScale = 1
        } else {
            let xRatio = targetSize.width / originalSize.width
            let yRatio = targetSize.height / originalSize.height
            
            if preserveAspectRatio {
                if targetSize.width <= 0 {
                    xScale = yRatio
                    yScale = yRatio
                    finalSize.width = originalSize.width * xScale
                } else if targetSize.height <= 0 {
                    xScale = xRatio
                    yScale = xRatio
                    finalSize.height = originalSize.height * yScale
                } else {
                    xScale = min(xRatio, yRatio)
                    yScale = min(xRatio, yRatio)
                    finalSize.width = originalSize.width * xScale
                    finalSize.height = originalSize.height * yScale
                }
            } else {
                if targetSize.width <= 0 {
                    finalSize.width = originalSize.width
                    xScale = 1
                    yScale = yRatio
                } else if targetSize.height <= 0 {
                    finalSize.height = originalSize.height
                    xScale = xRatio
                    yScale = 1
                } else {
                    xScale = xRatio
                    yScale = yRatio
                }
            }
        }
        
        let scaleTransform = CGAffineTransform(scaleX: xScale, y: yScale)
        var transform = CGAffineTransform.identity
        
        if preserveAspectRatio {
            let offsetX = (finalSize.width / xScale - originalSize.width) / 2
            let offsetY = (finalSize.height / yScale - originalSize.height) / 2
            transform = CGAffineTransform(translationX: offsetX, y: offsetY)
        }
        
        return (finalSize, scaleTransform.concatenating(transform))
    }
    
    private func testRender(image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        defer { UIGraphicsEndImageContext() }
        
        do {
            image.draw(in: CGRect(x: 0, y: 0, width: 1, height: 1))
            return image
        } catch {
            return nil
        }
    }
    
    // MARK: - Helper Methods
    private static func supportsVectorSVGImage() -> Bool {
        if #available(iOS 13.0, *) {
            return imageWithCGSVGDocumentSEL != nil && UIImage.responds(to: imageWithCGSVGDocumentSEL!)
        }
        return false
    }
    
    private static func isSVGFormat(for data: Data) -> Bool {
        guard !data.isEmpty else { return false }
        
        let searchData = kSVGTagEnd.data(using: .utf8)!
        let searchRange = NSRange(location: max(0, data.count - min(100, data.count)), length: min(100, data.count))
        
        let searchLength = min(100, data.count)
        let searchStart = data.count - searchLength
        let searchSubdata = data.subdata(in: searchStart..<data.count)
        return searchSubdata.range(of: searchData, options: .backwards) != nil
    }
}

// MARK: - CGSVGDocumentRef Type
private typealias CGSVGDocumentRef = UnsafeRawPointer


extension GMarkSVGRender {
    
    /// 根据原始尺寸和容器尺寸计算合适的目标尺寸
    /// - Parameters:
    ///   - originalSize: SVG原始尺寸
    ///   - containerSize: 容器尺寸
    ///   - scaleMode: 缩放模式
    /// - Returns: 计算后的目标尺寸
    func calculateTargetSize(originalSize: CGSize, containerSize: CGSize, scaleMode: ScaleMode = .aspectFit) -> CGSize {
        guard originalSize.width > 0 && originalSize.height > 0 &&
              containerSize.width > 0 && containerSize.height > 0 else {
            return originalSize
        }
        
        let widthRatio = containerSize.width / originalSize.width
        let heightRatio = containerSize.height / originalSize.height
        
        switch scaleMode {
        case .aspectFit:
            // 完全显示，可能有留白
            let scale = min(widthRatio, heightRatio)
            return CGSize(width: originalSize.width * scale, height: originalSize.height * scale)
            
        case .aspectFill:
            // 填满容器，可能被裁剪
            let scale = max(widthRatio, heightRatio)
            return CGSize(width: originalSize.width * scale, height: originalSize.height * scale)
            
        case .fill:
            // 拉伸填满，可能变形
            return containerSize
            
        case .scaleDown:
            // 只缩小不放大
            let scale = min(min(widthRatio, heightRatio), 1.0)
            return CGSize(width: originalSize.width * scale, height: originalSize.height * scale)
        }
    }
    
    /// 获取SVG原始尺寸（不渲染）
    func getSVGOriginalSize(from data: Data) -> CGSize? {
        guard let createFromData = Self.cgSVGDocumentCreateFromData,
              let getCanvasSize = Self.cgSVGDocumentGetCanvasSize,
              let release = Self.cgSVGDocumentRelease else {
            return nil
        }
        
        guard let document = createFromData(data as CFData, nil) else {
            return nil
        }
        
        defer { release(document) }
        
        let size = getCanvasSize(document)
        return size.width > 0 && size.height > 0 ? size : nil
    }
}

// MARK: - Scale Mode
extension GMarkSVGRender {
    enum ScaleMode {
        case aspectFit    // 保持比例，完全显示（类似UIView.ContentMode.scaleAspectFit）
        case aspectFill   // 保持比例，填满容器（类似UIView.ContentMode.scaleAspectFill）
        case fill         // 拉伸填满（类似UIView.ContentMode.scaleToFill）
        case scaleDown    // 只缩小不放大
    }
}


extension GMarkSVGRender {
    
    /// LaTeX SVG 渲染配置
    struct LaTeXRenderOptions {
        var baseFontSize: CGFloat = 16.0        // 基础字体大小
        var maxWidth: CGFloat = UIScreen.main.bounds.width - 32  // 最大宽度（屏幕宽度-边距）
        var minWidth: CGFloat = 20             // 最小宽度
        var scaleFactor: CGFloat = 6.0          // 额外缩放因子
        var allowHorizontalScroll: Bool = true  // 是否允许水平滚动
        var backgroundColor: UIColor = .clear   // 背景色
        
        static let `default` = LaTeXRenderOptions()
    }
    
    /// 渲染LaTeX SVG为适合屏幕显示的图片
    func renderLaTeXSVG(data: Data, options: LaTeXRenderOptions = .default) -> UIImage? {
        guard let originalSize = getSVGOriginalSize(from: data) else { return nil }
        debugPrint("SVG Original  Size: \(originalSize)")
        // 计算合适的显示尺寸
        let targetSize = calculateLaTeXDisplaySize(
            originalSize: originalSize,
            options: options
        )
        if targetSize.height > 1000 || targetSize.width > 1000 {
            debugPrint("SVG target Size is too large, using original size: \(originalSize)")
            return nil
        }
        debugPrint("SVG target Size: \(targetSize)")
        let renderOptions = RenderOptions(
            prefersBitmap: true,
            preserveAspectRatio: true, targetSize: targetSize
        )
        
        return decodedImage(with: data, options: renderOptions)
    }
    
    /// 批量渲染LaTeX SVG
    func batchRenderLaTeXSVGs(
        dataList: [Data],
        options: LaTeXRenderOptions = .default,
        completion: @escaping ([UIImage?]) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let images = dataList.map { data in
                self.renderLaTeXSVG(data: data, options: options)
            }
            
            DispatchQueue.main.async {
                completion(images)
            }
        }
    }
    
    private func calculateLaTeXDisplaySize(
        originalSize: CGSize,
        options: LaTeXRenderOptions
    ) -> CGSize {
        // LaTeX SVG通常基于特定的DPI，需要根据字体大小调整
        let baseScale = options.baseFontSize / 12.0 // 假设LaTeX基础字体为12pt
        let scaledSize = CGSize(
            width: originalSize.width * baseScale * options.scaleFactor,
            height: originalSize.height * baseScale * options.scaleFactor
        )
        
        var finalSize = scaledSize
        
        // 限制最大宽度（除非允许水平滚动）
        if !options.allowHorizontalScroll && scaledSize.width > options.maxWidth {
            let widthScale = options.maxWidth / scaledSize.width
            finalSize = CGSize(
                width: options.maxWidth,
                height: scaledSize.height * widthScale
            )
        }
        
        // 确保最小宽度
        if finalSize.width < options.minWidth {
            let widthScale = options.minWidth / finalSize.width
            finalSize = CGSize(
                width: options.minWidth,
                height: finalSize.height * widthScale
            )
        }
        
        return finalSize
    }
}
