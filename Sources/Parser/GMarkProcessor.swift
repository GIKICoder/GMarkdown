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

public class GMarkProcessor {
    public let parser: GMarkParser
    public let chunkGenerator: ChunkGenerator
    public init(parser: GMarkParser, chunkGenerator: ChunkGenerator) {
        self.parser = parser
        self.chunkGenerator = chunkGenerator
    }

    public func process(markdown: String) -> [GMarkChunk] {
        let markups = parser.parseMarkdownToMarkups(markdown: markdown)
        return chunkGenerator.generateChunks(from: markups)
    }
}
