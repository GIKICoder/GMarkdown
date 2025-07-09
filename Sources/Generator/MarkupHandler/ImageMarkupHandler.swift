//
//  ImageMarkupHandler.swift
//  GMarkdown
//
//  Created by GIKI on 2025/5/13.
//

import Foundation
import Markdown
import MPITextKit
import SwiftMath
import UIKit

public class ImageMarkupHandler: MarkupHandler {
    public init() {
        // 初始化代码
    }
    
    public func canHandle(_ markup: Markup) -> Bool {
        if markup is Paragraph {
            let markSub = markup.child(at: 0)
            return markSub is Markdown.Image
        }
        return markup is Markdown.Image
    }
    
    public func handle(_ markup: Markup, style _: Style?, imageLoader: (any ImageLoader)?) -> GMarkChunk {
        let chunk = GMarkChunk(chunkType: .Image, children: [markup])
        var imgSource: String?
        if markup is Paragraph {
            if let markSub = markup.child(at: 0) as? Markdown.Image {
                imgSource = markSub.source
            }
        }
        if let mark = markup as? Markdown.Image {
            imgSource = mark.source
        }
        chunk.source = imgSource ?? ""
        chunk.itemSize = CGSize(width: chunk.style.maxContainerWidth, height: 100)
        return chunk
    }
    
    func splitText(text: String) -> [String]? {
        let separators = CharacterSet(charactersIn: ";")
        let sentences = text.components(separatedBy: separators)
        
        let filteredSentences = sentences.filter { !$0.isEmpty }
        
        return filteredSentences
    }
    
    func splitTextToNums(text: String) -> [String]? {
        let separators = CharacterSet(charactersIn: ",")
        let sentences = text.components(separatedBy: separators)
        
        let filteredSentences = sentences.filter { !$0.isEmpty }
        
        return filteredSentences
    }
}

