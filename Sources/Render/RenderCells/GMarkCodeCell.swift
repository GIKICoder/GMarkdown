//
//  File.swift
//  GMarkdown
//
//  Created by GIKI on 2025/3/14.
//

import Foundation
import UIKit
import MPITextKit

class GMarkCodeCell: UICollectionViewCell, ChunkCellConfigurable {
    public var handlerChain: GMarkHandlerChain?

    static let reuseIdentifier = "GMarkCodeCell"
    private let codeView: GMarkdownCodeView = {
        let codeView = GMarkdownCodeView()
        return codeView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(codeView)
        codeView.onCopy = { [weak self] copyText in
            guard let self = self else { return }
            self.handlerChain?.handle(.codeBlockCopied(copyText))
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        codeView.frame = contentView.bounds
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with chunk: GMarkChunk) {
        codeView.markChunk = chunk
    }
}
