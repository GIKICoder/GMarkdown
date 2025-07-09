//
//  File.swift
//  GMarkdown
//
//  Created by GIKI on 2025/5/13.
//

import Foundation
import Markdown
import MPITextKit
import SwiftMath
import UIKit

// MARK: - MarkupHandler Implementations


public class BlockQuoteMarkupHandler: MarkupHandler {
    public init() {
        // 初始化代码
    }
    
    public func canHandle(_: Markup) -> Bool {
        //    return markup is BlockQuote
        return false
    }
    
    public func handle(_ markup: Markup, style _: Style?, imageLoader: (any ImageLoader)?) -> GMarkChunk {
        return GMarkChunk(chunkType: .BlockQuote, children: [markup])
    }
}

public class ThematicBreakHandler: MarkupHandler {
    public init() {
        
    }
    
    public func canHandle(_ markup: Markup) -> Bool {
        return markup is ThematicBreak
    }
    
    public func handle(_ markup: Markup, style _: Style?, imageLoader: (any ImageLoader)?) -> GMarkChunk {
        let chunk = GMarkChunk(chunkType: .Thematic, children: [markup])
        chunk.itemSize = CGSize(width: chunk.style.maxContainerWidth, height: 30)
        return chunk
    }
}
