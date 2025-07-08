//
//  MDAsyncImageAttachedProvider.swift
//  GMarkdown
//
//  Created by 巩柯 on 2025/7/3.
//

import UIKit
import Markdown

class MDAsyncImageAttachedProvider: MarkdownAttachedViewProvider {

    let url:String
    
    lazy var imageView = UIImageView()
    
    var markup: Image?
    var style:Style?
    var imageloader: ImageLoader?
    
    init(markup: Image, style:Style, imageloader: ImageLoader? = nil) {
        self.url = markup.source ?? ""
        self.markup = markup
        self.style = style
        self.imageloader = imageloader
    }
    
    func instantiateView(for attachment: MarkdownAttachment, in behavior: MarkdownAttachingBehavior) -> UIView {
        if let imageloader {
            imageloader.loadImage(from: url, into: self.imageView)
        } else {
            loadImageFromUrl()
        }
        return self.imageView
    }

    func bounds(for attachment: MarkdownAttachment, textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint) -> CGRect {
        guard let style = self.style else {
            return CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
        }
        return CGRect(origin: .zero, size: CGSize(width: style.maxContainerWidth, height: style.maxContainerWidth))
    }
    
    func loadImageFromUrl() {
        guard !url.isEmpty, let imageURL = URL(string: url) else {
            print("Invalid URL: \(url)")
            return
        }
        
        // 设置加载状态
        DispatchQueue.main.async {
            self.imageView.backgroundColor = UIColor.systemGray6
            self.imageView.contentMode = .scaleAspectFit
        }
        
        // 检查缓存
        let cache = URLCache.shared
        let request = URLRequest(url: imageURL)
        
        if let cachedResponse = cache.cachedResponse(for: request),
           let image = UIImage(data: cachedResponse.data) {
            // 使用缓存的图片
            DispatchQueue.main.async {
                self.imageView.image = image
                self.imageView.backgroundColor = UIColor.clear
            }
            return
        }
        
        // 从网络加载
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.showErrorState()
                }
                return
            }
            
            guard let data = data,
                  let response = response,
                  let image = UIImage(data: data) else {
                print("Invalid image data")
                DispatchQueue.main.async {
                    self?.showErrorState()
                }
                return
            }
            
            // 缓存响应
            let cachedResponse = CachedURLResponse(response: response, data: data)
            cache.storeCachedResponse(cachedResponse, for: request)
            
            // 更新UI
            DispatchQueue.main.async {
                self?.imageView.image = image
                self?.imageView.backgroundColor = UIColor.clear
            }
        }
        
        task.resume()
    }

    private func showErrorState() {
        imageView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
    }

}
