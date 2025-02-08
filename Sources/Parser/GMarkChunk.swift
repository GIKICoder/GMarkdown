//
//  GMarkChunk.swift
//  GMarkRender
//
//  Created by GIKI on 2025/04/27.
//

import CryptoKit
import Foundation
import Markdown
import MPITextKit
import UIKit

// MARK: - ChunkType

public enum ChunkType: Int {
    case Text = 0
    case Code = 1
    case Table = 2
    case BlockQuote = 3
    case Thematic = 4
    case Image = 5
    case Latex = 6
    case Html = 7
}

// MARK: - GMarkChunk

/// A class representing a parsed Markdown chunk with various rendering attributes.
/// Conforms to `Hashable` and `Equatable` to support diffing based on content changes.
public final class GMarkChunk: Hashable, Sendable {
    
    // MARK: - Properties
    
    /// A unique identifier for the chunk, provided externally.
    public var identifier: String = UUID().uuidString
    
    public var chunkIndex: Int = 0
    
    /// The children markup elements of this chunk.
    public var children: [Markup] = []
    
    /// The type of the chunk.
    public var chunkType: ChunkType = .Text
    
    /// The attributed text representation of the chunk.
    public var attributedText: NSAttributedString = NSAttributedString(string: "")
    
    /// The text renderer for the chunk.
    public var textRender: MPITextRenderer?
    
    /// The text renderer used when the chunk is truncated.
    public var truncationTextRender: MPITextRenderer?
    
    /// The size of the chunk item.
    public var itemSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 0)
    
    /// The size of the truncated chunk item.
    public var truncationItemSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 0)
    
    /// The style applied to the chunk.
    public var style: Style = MarkdownStyle.defaultStyle()
    
    /// The table renderer, if the chunk is a table.
    public var tableRender: GMarkTableRender?
    
    /// The programming language, if the chunk is a code block.
    public var language: String = ""
    
    /// The source code or content of the chunk.
    public var source: String = ""
    
    /// The template source, if applicable.
    public var sourceTemplate: String = ""
    
    /// Line numbers or related metadata for the source, if applicable.
    public var sourceNumbers: [String] = []
    
    /// The size of the code block.
    public var codeSize: CGSize = .zero
    
    /// The size of the LaTeX block.
    public var latexSize: CGSize = .zero
    
    /// The image rendered from LaTeX, if applicable.
    public var latexImage: UIImage?
    
    public var hashKey = UUID().uuidString
    
    // MARK: - Initializers
    
    // 无参构造器
    public init() {
        self.identifier = UUID().uuidString
        setupStyle()
        updateHashKey()
    }
    
    // 基础构造器 - identifier可选
    public init(identifier: String = UUID().uuidString) {
        self.identifier = identifier
        setupStyle()
        updateHashKey()
    }
    
    // 便利构造器 - chunkType
    public convenience init(chunkType: ChunkType) {
        self.init()
        self.chunkType = chunkType
        updateHashKey()
    }
    
    // 便利构造器 - children
    public convenience init(children: [Markup]) {
        self.init()
        self.children = children
        updateHashKey()
    }
    
    // 便利构造器 - chunkType和children
    public convenience init(chunkType: ChunkType, children: [Markup]) {
        self.init()
        self.chunkType = chunkType
        self.children = children
        updateHashKey()
    }
    
    // 便利构造器 - 完整参数
    public convenience init(identifier: String = UUID().uuidString,
                            chunkType: ChunkType = .Text,
                            children: [Markup] = []) {
        self.init(identifier: identifier)
        self.chunkType = chunkType
        self.children = children
        updateHashKey()
    }
    
    private func setupStyle() {
        style.useMPTextKit = true
        style.codeBlockStyle.customRender = true
    }
    
    public func updateHashKey() {
        hashKey = combineHash()
    }
    
    // MARK: - Hashable & Equatable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(hashKey)
    }
    
    public static func == (lhs: GMarkChunk, rhs: GMarkChunk) -> Bool {
        return lhs.identifier == rhs.identifier
        && lhs.hashKey == rhs.hashKey
    }
    
    // MARK: - Public Methods
    
    /// Generates a unique hash key based on the chunk's properties.
    ///
    /// - Returns: A unique string representing the hash key.
    public func combineHash() -> String {
        var customHash = "\(chunkIndex)" + "-" + "\(chunkType.rawValue)" + "-" + identifier
        switch chunkType {
        case .Text, .Latex:
            let text = attributedText.string
            customHash += text.md5()
        case .Code:
            let text = attributedText.string
            customHash += text.md5()
            customHash += language
        case .Table:
            let tableContent = tableRender?.markTable.contents ?? generateRandomString()
            if !tableContent.isEmpty {
                customHash += tableContent.md5()
            } else {
                customHash += generateRandomString()
            }
        case .Image:
            customHash += sourceTemplate
            customHash += source
        case .Thematic:
            customHash += generateRandomString()
        default:
            customHash += generateRandomString()
            break
        }
        
        customHash += String(format: "%.0f", ceil(itemSize.height))
        customHash += String(format: "%.0f", ceil(itemSize.width))
        
        return customHash
    }
    
    // MARK: - Private Methods
    
    /// Performs common initialization tasks.
    private func commonInitialization() {
        style.useMPTextKit = true
        style.codeBlockStyle.customRender = true
    }
    
    /// Generates a random string based on the current timestamp and a random number.
    ///
    /// - Returns: A random string.
    private func generateRandomString() -> String {
            let timestamp = Int(Date().timeIntervalSince1970)
             let randomNumber = Int.random(in: 0 ... 10000)
            let resultString = "\(timestamp)\(randomNumber)"
            return resultString + UUID().uuidString
        }
}


// MARK: - Extensions

private extension Data {
    /// Computes the MD5 hash of the data.
    ///
    /// - Returns: A hexadecimal string representation of the MD5 hash.
    func md5Hash() -> String {
        let digest = Insecure.MD5.hash(data: self)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}

private extension String {
    /// Computes the MD5 hash of the string.
    ///
    /// - Returns: A hexadecimal string representation of the MD5 hash.
    func md5() -> String {
        self.data(using: .utf8)?.md5Hash() ?? ""
    }
}
