//
//  MDTableAttachedProvider.swift
//  GMarkdown
//
//  Created by 巩柯 on 2025/7/3.
//

import UIKit

class MDTableAttachedProvider: MarkdownAttachedViewProvider {
    
    let url:String
    
    let imageView = UIImageView()
    
    var chunk: GMarkChunk?
    
    init(url: String) {
        self.url = url
    }
    
    init(chunk: GMarkChunk) {
        self.url = chunk.source
        self.chunk = chunk
    }
    
    func instantiateView(for attachment: MarkdownAttachment, in behavior: MarkdownAttachingBehavior) -> UIView {
        self.imageView.backgroundColor = .orange
        return self.imageView
    }

    func bounds(for attachment: MarkdownAttachment, textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint) -> CGRect {
        guard let chunk = self.chunk else {
            return CGRect(origin: .zero, size: .zero)
        }
        return CGRect(origin: .zero, size: chunk.itemSize)
    }
}
