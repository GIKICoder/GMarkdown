//
//  CodeAttachedProvider.swift
//  GMarkdown
//
//  Created by 巩柯 on 2025/6/28.
//

import UIKit

class CodeAttachedProvider: TextAttachedViewProvider {

    let url:String
    
    let imageView = UIImageView()
    
    init(url: String) {
        self.url = url
    }
    
    func instantiateView(for attachment: SubviewTextAttachment, in behavior: SubviewAttachingTextViewBehavior) -> UIView {
        self.imageView.backgroundColor = .orange
        return self.imageView
    }

    func bounds(for attachment: SubviewTextAttachment, textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint) -> CGRect {
        return CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
    }
}
