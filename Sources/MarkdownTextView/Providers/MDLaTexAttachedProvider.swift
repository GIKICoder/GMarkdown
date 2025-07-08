//
//  MDLaTexAttachedProvider.swift
//  GMarkdown
//
//  Created by GIKI on 2025/7/7.
//


import UIKit
import Markdown

class MDLaTexAttachedProvider: MarkdownAttachedViewProvider {
    
    private lazy var latexImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let style: Style
    private let laTexImage: UIImage
    init(laTexImage: UIImage, style:Style) {
        self.laTexImage = laTexImage
        self.style = style
    }
    
    func instantiateView(for attachment: MarkdownAttachment, in behavior: MarkdownAttachingBehavior) -> UIView {
        self.latexImageView.image = laTexImage
        return self.latexImageView
    }

    func bounds(for attachment: MarkdownAttachment, textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint) -> CGRect {
        return CGRect(origin: .zero, size: laTexImage.size)
    }
}
