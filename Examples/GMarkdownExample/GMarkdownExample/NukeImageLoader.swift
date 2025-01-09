//
//  NukeImageLoader.swift
//  GMarkdownExample
//
//  Created by GIKI on 2024/8/1.
//

import Foundation
import UIKit
import Nuke
import NukeExtensions
import NukeUI


class NukeImageLoader: ImageLoader {
    
    @MainActor func loadImage(from source: String, into imageView: UIImageView) {
        guard let url = URL(string: source) else { return }
        
        
        let options = ImageLoadingOptions(
            placeholder: UIImage(ciImage: .gray),
            transition: .fadeIn(duration: 0.33)
        )
        NukeExtensions.loadImage(with: url, options: options, into: imageView) { result in}
    }
    
    func download(from source: String) async -> UIImage? {
        do {
            let request = ImageRequest(
                url: URL(string: source),
                priority: .high
            )
            let image = try await ImagePipeline.shared.image(for: request)
            return image
        } catch {
            print("Error downloading image: \(error)")
            return nil
        }
    }
    
}

extension UIImage {
    
    /// 创建一个纯色的图片
    /// - Parameters:
    ///   - color: 图片的颜色
    ///   - size: 图片的尺寸
    /// - Returns: 生成的纯色图片
    static func image(withColor color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
