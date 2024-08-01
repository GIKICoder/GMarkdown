//
//  GMarkChunkGenerator.swift
//  GMarkRender
//
//  Created by GIKI on 2024/8/1.
//

import Foundation
import Markdown
import UIKit
import MPITextKit
// MARK: - Protocols

protocol ChunkGenerator {
  func generateChunks(from markups: [Markup]) -> [GMarkChunk]
}

protocol MarkupHandler {
  func canHandle(_ markup: Markup) -> Bool
  func handle(_ markup: Markup) -> GMarkChunk
}


// MARK: - ChunkGenerator Implementation

class GMarkChunkGenerator: ChunkGenerator {
  private var handlers: [MarkupHandler]
  private let maxAttributedStringLength = 2000
  
  init(handlers: [MarkupHandler] = [
    TableMarkupHandler(),
    CodeBlockMarkupHandler(),
    BlockQuoteMarkupHandler(),
    ThematicBreakHandler()
  ]) {
    self.handlers = handlers
  }
  
  func generateChunks(from markups: [Markup]) -> [GMarkChunk] {
    var chunks: [GMarkChunk] = []
    var currentChunk = GMarkChunk(chunkType: .Text)
    
    for markup in markups {
      if let handler = handlers.first(where: { $0.canHandle(markup) }) {
        if !currentChunk.children.isEmpty {
          chunks.append(currentChunk)
          currentChunk = GMarkChunk(chunkType: .Text)
        }
        chunks.append(handler.handle(markup))
      } else {
        var visitor = GMarkupVisitor(style: currentChunk.style)
        let attributeText = visitor.visit(markup)
        
        if (currentChunk.attributeText?.length ?? 0) + attributeText.length > maxAttributedStringLength {
          chunks.append(currentChunk)
          currentChunk = GMarkChunk(children: [], chunkType: .Text)
        }
        currentChunk.children.append(markup)
        let mutableAttributeText = NSMutableAttributedString(attributedString: currentChunk.attributeText ?? NSAttributedString())
        mutableAttributeText.append(attributeText)
        currentChunk.attributeText = mutableAttributeText
        currentChunk.generatorTextRender()
      }
    }
    
    if !currentChunk.children.isEmpty {
      chunks.append(currentChunk)
    }
    
    return chunks
  }
}

// MARK: - MarkupHandler Implementations

class TableMarkupHandler: MarkupHandler {
  func canHandle(_ markup: Markup) -> Bool {
    return markup is Table
  }
  
  func handle(_ markup: Markup) -> GMarkChunk {
    var chunk =  GMarkChunk(children: [markup], chunkType: .Table)
    guard let markup = markup as! Table? else {
      return chunk
    }
    chunk.generateTable(markup: markup)
    return chunk
  }
}

class CodeBlockMarkupHandler: MarkupHandler {
  func canHandle(_ markup: Markup) -> Bool {
    return markup is CodeBlock
  }
  
  func handle(_ markup: Markup) -> GMarkChunk {
    
    var chunk = GMarkChunk(children: [markup], chunkType: .Code)
    guard let markup = markup as! CodeBlock? else {
      return chunk
    }
    chunk.generateCode(markup: markup)
    return chunk
  }
}

class BlockQuoteMarkupHandler: MarkupHandler {
  func canHandle(_ markup: Markup) -> Bool {
//    return markup is BlockQuote
    return false
  }
  
  func handle(_ markup: Markup) -> GMarkChunk {
    return GMarkChunk(children: [markup], chunkType: .BlockQuote)
  }
}

class ThematicBreakHandler: MarkupHandler {
  func canHandle(_ markup: Markup) -> Bool {
    return markup is ThematicBreak
  }
  
  func handle(_ markup: Markup) -> GMarkChunk {
    var chunk = GMarkChunk(children: [markup], chunkType: .Thematic)
    chunk.itemSize = CGSize(width: chunk.style.maxContainerWidth, height: 30)
    return chunk
  }
}

// MARK: - text Chunk
extension GMarkChunk {

  mutating func generatorTextRender() {
    
    guard let attr = attributeText else {
      return
    }
    let builder = MPITextRenderAttributesBuilder()
    builder.attributedText = attr
    builder.maximumNumberOfLines = 0
    let renderAttributes = MPITextRenderAttributes(builder: builder)
    textRender =  MPITextRenderer(renderAttributes: renderAttributes, constrainedSize: CGSize(width: style.maxContainerWidth, height: CGFLOAT_MAX))
    
    itemSize = CGSize(width: style.maxContainerWidth, height: textRender?.size().height ?? 0.0)
  }
  
}



// MARK: - Code Chunk
extension GMarkChunk {
  
  mutating func generateCode(markup: CodeBlock) {
    language = markup.language
    var visitor = GMarkupVisitor(style: style)
    attributeText = visitor.visit(markup)
    calculateCode()
  }
  
  mutating func calculateCode() {
    
    guard let attr = attributeText else {
      return
    }
    let builder = MPITextRenderAttributesBuilder()
    builder.attributedText = attr
    builder.maximumNumberOfLines = 0
    let renderAttributes = MPITextRenderAttributes(builder: builder)
    let fitsSize = CGSize(width: style.maxContainerWidth*2, height: CGFLOAT_MAX)
    textRender =  MPITextRenderer(renderAttributes: renderAttributes, constrainedSize:fitsSize)
    codeSize = textRender?.size() ?? CGSize(width: style.maxContainerWidth, height: 0)
    let itemHeight = style.codeBlockStyle.padding.top + 32 + 8 + codeSize.height + 8 + style.codeBlockStyle.padding.bottom
    itemSize = CGSize(width: style.maxContainerWidth, height: itemHeight)
  }
}

// MARK: - Table Chunk
extension GMarkChunk {
  
  mutating func generateTable(markup: Table) {
    var style = MarkdownStyle.defaultStyle()
    style.useMPTextKit = true
    style.imageStyle.size = CGSize(width: 60, height: 60)
    var visitor = GMarkupTableVisitor(style: style)
    let table = visitor.visit(markup)
    calculateTable(table: table)
  }
  mutating func calculateTable(table:GMarkTable?) {
    
    guard let table = table else {
      return
    }
    tableRender = GMarkTableRender(markTable: table, style:style)
    itemSize = CGSize(width: style.maxContainerWidth, height: tableRender?.tableHeight ?? 0)
  }
}


struct GMarkTableRender {
  let markTable: GMarkTable
  let style: Style
  var headerRenders: [MPITextRenderer]? = []
  var bodyRenders: [[MPITextRenderer]]? = []
  var tableHeight: CGFloat?
  init(markTable: GMarkTable,style:Style) {
    self.markTable = markTable
    self.style = style
    setupTableRender()
  }
  
  mutating func setupTableRender() {
    
    let maxW = style.tableStyle.cellMaximumWidth
    let defaultH = style.tableStyle.cellHeight
    let paddingH = style.tableStyle.cellPadding.top + style.tableStyle.cellPadding.bottom
    var height = defaultH
    markTable.headers?.enumerated().forEach({ _,attr in
      let builder = MPITextRenderAttributesBuilder()
      builder.attributedText = attr
      builder.maximumNumberOfLines = UInt(style.tableStyle.maximumNumberOfLines)
      let renderAttributes = MPITextRenderAttributes(builder: builder)
      let fitsSize = CGSize(width: maxW, height: CGFLOAT_MAX)
      let textRender =  MPITextRenderer(renderAttributes: renderAttributes, constrainedSize:fitsSize)
      headerRenders?.append(textRender)
      height = max(textRender.size().height+paddingH, height)
    })
  
    markTable.bodys?.enumerated().forEach({ _,attrs in
      var rowRenders: [MPITextRenderer] = []
      var maxRowHeight = 0.0
      attrs.enumerated().forEach { _,attr in
        let builder = MPITextRenderAttributesBuilder()
        builder.attributedText = attr
        builder.maximumNumberOfLines = UInt(style.tableStyle.maximumNumberOfLines)
        let renderAttributes = MPITextRenderAttributes(builder: builder)
        let fitsSize = CGSize(width: maxW, height: CGFLOAT_MAX)
        let textRender =  MPITextRenderer(renderAttributes: renderAttributes, constrainedSize:fitsSize)
        rowRenders.append(textRender)
        maxRowHeight = max(textRender.size().height+paddingH, defaultH)
      }
      height += maxRowHeight
      bodyRenders?.append(rowRenders)
    })
    
    height += style.tableStyle.padding.top+style.tableStyle.padding.bottom
    tableHeight = height
  }
  
}
