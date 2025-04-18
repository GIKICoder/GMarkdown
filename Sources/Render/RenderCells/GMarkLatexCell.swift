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
    
    private var svgView: SVGView = {
        let view = SVGView(frame: .zero)
        view.isHidden = true
        return view
    }()
    
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
        scrollView.addSubview(svgView)
        scrollView.frame = contentView.bounds
    }
    
    func configure(with chunk: GMarkChunk) {
        if let image = chunk.latexImage {
            svgView.isHidden = true
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
            svgView.isHidden = false
            var frame = CGRect(x: 0, y: chunk.style.codeBlockStyle.padding.top, width: chunk.latexSize.width, height: chunk.latexSize.height)
            if chunk.latexSize.width < CGRectGetWidth(scrollView.frame) {
                let left = (CGRectGetWidth(scrollView.frame) - chunk.latexSize.width) * 0.5
                frame = CGRect(x: left, y: chunk.style.codeBlockStyle.padding.top, width: chunk.latexSize.width, height: chunk.latexSize.height)
            }
            svgView.node = node
            svgView.frame = frame
            scrollView.contentSize = CGSize(width: chunk.latexSize.width, height: chunk.latexSize.height)
        }
    }
}
