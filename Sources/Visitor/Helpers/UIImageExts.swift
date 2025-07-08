//
//  UIImageExts.swift
//  GMarkdown
//
//  Created by GIKI on 2025/7/7.
//

import UIKit

extension UIImage {
    /// 根据给定的最大宽度调整图片大小，同时保持比例不变。
    /// - Parameter maxWidth: 图片的最大宽度。
    /// - Returns: 调整后的UIImage实例。如果原始宽度小于或等于maxWidth，则返回原图。
    func resized(toMaxWidth maxWidth: CGFloat) -> UIImage {
        // 检查是否需要调整大小
        if self.size.width <= maxWidth {
            return self
        }
        
        // 计算缩放比例以保持纵横比
        let scaleFactor = maxWidth / self.size.width
        let newHeight = self.size.height * scaleFactor
        let newSize = CGSize(width: maxWidth, height: newHeight)
        
        // 开始图形上下文并绘制调整后的图片
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let resizedImage {
            return resizedImage
        }
        return self
    }
}

