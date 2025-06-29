//
//  File.swift
//  GMarkdown
//
//  Created by GIKI on 2025/3/14.
//

import Foundation
import UIKit
import MPITextKit
import Macaw

class GMarkLatexCell: UICollectionViewCell, ChunkCellConfigurable {
    static let reuseIdentifier = "GMarkLatexCell"
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        return sv
    }()

    private let latexImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var svgView: SVGView?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required public init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = contentView.bounds
    }

    func setupUI() {
        contentView.addSubview(scrollView)
        scrollView.addSubview(latexImageView)
        scrollView.frame = contentView.bounds
    }
    
    func configure(with chunk: GMarkChunk) {
        if let image = chunk.latexImage {
            latexImageView.isHidden = false
            latexImageView.image = image
            if image.size.width >= CGRectGetWidth(scrollView.frame) {
                latexImageView.frame = CGRect(x: 0, y: chunk.style.codeBlockStyle.padding.top, width: image.size.width, height: image.size.height)
            } else {
                let left = (CGRectGetWidth(scrollView.frame) - image.size.width) * 0.5
                latexImageView.frame = CGRect(x: left, y: chunk.style.codeBlockStyle.padding.top, width: image.size.width, height: image.size.height)
            }
            scrollView.contentSize = CGSize(width: image.size.width, height: image.size.height)
        } else if let node = chunk.latexNode {
            latexImageView.isHidden = true
            svgView?.removeFromSuperview()
            svgView = nil
            var frame = CGRect(x: 0, y: chunk.style.codeBlockStyle.padding.top, width: chunk.latexSize.width, height: chunk.latexSize.height)
            if chunk.latexSize.width < CGRectGetWidth(scrollView.frame) {
                let left = (CGRectGetWidth(scrollView.frame) - chunk.latexSize.width) * 0.5
                frame = CGRect(x: left, y: chunk.style.codeBlockStyle.padding.top, width: chunk.latexSize.width, height: chunk.latexSize.height)
            }
    
            // Creating a temporary SVG view for rendering
            let tempSVGView = SVGView(node: node, frame: CGRect(origin: .zero, size: frame.size))
            tempSVGView.backgroundColor = .clear
            // Render the SVG as an image
            UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
            if let context = UIGraphicsGetCurrentContext() {
                tempSVGView.layer.render(in: context)
                let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                if let renderedImage {
                    GMarkCachedManager.shared.setLatexCache(renderedImage, for: chunk.latexKey ?? chunk.attributedText.string)

                    // Display the rendered image
                    latexImageView.isHidden = false
                    latexImageView.image = renderedImage
                    latexImageView.frame = frame
                    scrollView.contentSize = CGSize(width: renderedImage.size.width, height: renderedImage.size.height)
                }
            }
        }
    }
}
