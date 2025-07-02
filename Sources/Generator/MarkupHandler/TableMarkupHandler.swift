//
//  TableMarkupHandler.swift
//  GMarkdown
//
//  Created by GIKI on 2025/5/13.
//

import Foundation
import Markdown
import MPITextKit
import SwiftMath
import UIKit

public class TableMarkupHandler: MarkupHandler {
    public init() {
        // 初始化代码
    }
    
    public func canHandle(_ markup: Markup) -> Bool {
        return markup is Table
    }
    
    public func handle(_ markup: Markup, style: Style?) -> GMarkChunk {
        let chunk = GMarkChunk(chunkType: .Table, children: [markup])
        if let style = style {
            chunk.style = style
        }
        guard let markup = markup as! Table? else {
            return chunk
        }
        chunk.generateTable(markup: markup)
        return chunk
    }
}

// MARK: - Table Chunk

extension GMarkChunk {
    func generateTable(markup: Table) {
        var style = style
        style.useMPTextKit = true
        style.imageStyle.size = CGSize(width: 60, height: 60)
        var visitor = GMarkupTableVisitor(style: style)
        let table = visitor.visit(markup)
        calculateTable(table: table)
        
        updateHashKey()
    }
    
    func calculateTable(table: GMarkTable?) {
        guard let table = table else {
            return
        }
        tableRender = GMarkTableLayout(markTable: table, style: style)
        itemSize = CGSize(width: style.maxContainerWidth, height: tableRender?.tableHeight ?? 0)
    }
}
