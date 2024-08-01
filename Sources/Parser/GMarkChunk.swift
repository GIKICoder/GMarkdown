//
//  GMarkChunk.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/26.
//

import Foundation
import UIKit
import Markdown
import MPITextKit

enum ChunkType {
  case Text
  case Code
  case Table
  case BlockQuote
  case Thematic
}

struct GMarkChunk: Hashable {
  let id = UUID()
  
  var children: [Markup] = []
  
  var chunkType: ChunkType = .Text
  
  var attributeText: NSAttributedString?
  
  var textRender: MPITextRenderer?
  
  var itemSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 0)
  
  var style = MarkdownStyle.defaultStyle()
  
  var tableRender: GMarkTableRender?
  
  var language: String?
  
  var codeSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 0)
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: GMarkChunk, rhs: GMarkChunk) -> Bool {
    return lhs.id == rhs.id
  }
  
  init(children:[Markup], chunkType: ChunkType) {
    self.init(children: children,
              chunkType: chunkType,
              attributeText: nil,
              textRender: nil,
              itemSize: CGSize(width: UIScreen.main.bounds.width, height: 0),
              style: MarkdownStyle.defaultStyle(),
              tableRender: nil,
              language: nil, codeSize: .zero)
  }
  
  init(chunkType: ChunkType) {
    self.init(children: [],
              chunkType: chunkType,
              attributeText: nil,
              textRender: nil,
              itemSize: CGSize(width: UIScreen.main.bounds.width, height: 0),
              style: MarkdownStyle.defaultStyle(),
              tableRender: nil,
              language: nil, codeSize: .zero)
  }
  
  
  private init(children: [Markup], chunkType: ChunkType, attributeText: NSAttributedString? = nil, textRender: MPITextRenderer? = nil, itemSize: CGSize, style: MarkdownStyle = MarkdownStyle.defaultStyle(), tableRender: GMarkTableRender? = nil, language: String? = nil, codeSize: CGSize) {
    self.children = children
    self.chunkType = chunkType
    self.attributeText = attributeText
    self.textRender = textRender
    self.itemSize = itemSize
    self.style = style
    self.tableRender = tableRender
    self.language = language
    self.codeSize = codeSize
    
    commonInitialization()
  }
  
  mutating func commonInitialization() {
    style.useMPTextKit = true
    style.codeBlockStyle.customRender = true
    style.maxContainerWidth = UIScreen.main.bounds.width
  }
  
}

