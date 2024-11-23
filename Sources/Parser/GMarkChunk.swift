//
//  GMarkChunk.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/26.
//

import CryptoKit
import Foundation
import Markdown
import MPITextKit
import UIKit

public enum ChunkType: Int {
    case Text = 0
    case Code = 1
    case Table = 2
    case BlockQuote = 3
    case Thematic = 4
    case Image = 5
    case Latex = 6
    case Html = 7
    case DotlineType = 8
    case DotlineCard = 9
}


public struct GMarkChunk: Hashable {
    let id = UUID()

    public var children: [Markup] = []

    public var chunkType: ChunkType = .Text

    public var attributeText: NSAttributedString?

    public var textRender: MPITextRenderer?

    public var truncationTextRender: MPITextRenderer?

    public var itemSize: CGSize = .init(width: UIScreen.main.bounds.width, height: 0)

    public var truncationItemSize: CGSize = .init(width: UIScreen.main.bounds.width, height: 0)

    public var style: Style = MarkdownStyle.defaultStyle()

    public var tableRender: GMarkTableRender?

    public var language: String?

    public var source: String?
    public var sourceTemplate: String?
    public var sourceNums: [String]?

    public var codeSize: CGSize = .init(width: UIScreen.main.bounds.width, height: 0)

    public var latexSize: CGSize = .init(width: UIScreen.main.bounds.width, height: 0)

    public var latexImage: UIImage?
    
    public var cardType: String?
    public var cardTitle: String?
    public var cardHighlight: String?
    public var cardImages: [[String:Any]]?

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: GMarkChunk, rhs: GMarkChunk) -> Bool {
        return lhs.id == rhs.id
    }

    public func hashKey() -> String {
        var tempKey = ""
        if chunkType == .Text || chunkType == .Latex {
            tempKey = String(chunkType.rawValue) + tempKey
            if let text = attributeText?.string {
                tempKey = tempKey + text.md5()
            }
        } else if chunkType == .Code {
            tempKey = String(chunkType.rawValue) + tempKey
            if let text = attributeText?.string {
                tempKey = tempKey + text.md5() + (language ?? "")
            }
        } else if chunkType == .Table {
            tempKey = String(chunkType.rawValue) + tempKey
            if let tableContent = tableRender?.markTable.contents {
                tempKey = tableContent.md5() + tempKey
            } else {
                tempKey = generateRandomString()
            }
        } else if chunkType == .Image {
            tempKey = String(chunkType.rawValue) + tempKey
            tempKey = tempKey + (sourceTemplate ?? "") + (source ?? "")
        } else if chunkType == .DotlineCard {
            tempKey = String(chunkType.rawValue) + tempKey
            tempKey = tempKey + (cardTitle ?? "") + (cardHighlight ?? "") 
            if let text = attributeText?.string {
                tempKey = tempKey + text.md5()
            }
        }
        if tempKey.count > 0 {
            tempKey = tempKey + String(ceil(itemSize.height))
            return tempKey
        }
        tempKey = String(chunkType.rawValue) + tempKey + String(ceil(itemSize.height)) + id.uuidString
        return tempKey
    }

    func generateRandomString() -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let randomNumber = Int.random(in: 0 ... 10000)
        let resultString = "\(timestamp)\(randomNumber)"
        return resultString
    }

    init(children: [Markup], chunkType: ChunkType) {
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
    }
}

private extension Data {
    func md5() -> String {
        let digest = Insecure.MD5.hash(data: self)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}

private extension String {
    func md5() -> String {
        data(using: .utf8)?.md5() ?? ""
    }
}
