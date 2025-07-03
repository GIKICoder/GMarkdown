//
//  MDCodeAttachedProvider.swift
//  GMarkdown
//
//  Created by 巩柯 on 2025/7/3.
//

import UIKit

class MDCodeAttachedProvider: MarkdownAttachedViewProvider {
    
    private let codeView: GMarkdownCodeView = {
        let codeView = GMarkdownCodeView()
        return codeView
    }()
    
    let chunk: GMarkChunk
    
    init(chunk: GMarkChunk) {
        self.chunk = chunk
    }
    
    func instantiateView(for attachment: MarkdownAttachment, in behavior: MarkdownAttachingBehavior) -> UIView {
        codeView.markChunk = chunk
        return self.codeView
    }

    func bounds(for attachment: MarkdownAttachment, textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint) -> CGRect {
        return CGRect(origin: .zero, size: chunk.itemSize)
    }
}
