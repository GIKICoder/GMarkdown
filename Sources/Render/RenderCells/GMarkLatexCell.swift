//
//  File.swift
//  GMarkdown
//
//  Created by GIKI on 2025/3/14.
//

import Foundation
import UIKit
import MPITextKit

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
        } 
    }
}
