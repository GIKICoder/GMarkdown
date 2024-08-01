//
//  GMarkProcessor.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/31.
//

import Foundation
import Markdown
import UIKit

// MARK: - MarkdownProcessor

class GMarkProcessor {
    private let parser: GMarkParser
    private let chunkGenerator: ChunkGenerator
    
    init(parser: GMarkParser = GMarkParser(), chunkGenerator: ChunkGenerator = GMarkChunkGenerator()) {
        self.parser = parser
        self.chunkGenerator = chunkGenerator
    }
    
    func process(markdown: String) -> [GMarkChunk] {
        let markups = parser.parseMarkdownToMarkups(markdown: markdown)
        return chunkGenerator.generateChunks(from: markups)
    }
}

