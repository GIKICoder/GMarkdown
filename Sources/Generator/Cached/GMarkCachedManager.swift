//
//  GMarkCachedManager.swift
//  GMarkdown
//
//  Created by 巩柯 on 2025/6/28.
//

import Foundation
import UIKit
import CryptoKit

final class GMarkCachedManager {
    
    static let shared = GMarkCachedManager()
    
    private init() {}
    
    private let latexCached = GMarkLRUCache<String, UIImage>(totalCostLimit: 50, countLimit: 30)
    
    private let attributedCached = GMarkLRUCache<String, NSAttributedString>(totalCostLimit: 100, countLimit: 50)
    
    // MARK: - Latex Cache
    
    public func setLatexCache(_ image: UIImage, for key: String) {
        latexCached.setValue(image, forKey: key.cacheKey)
    }
    
    public func getLatexCache(for key: String) -> UIImage? {
        return latexCached.value(forKey: key.cacheKey)
    }
    
    public func clearLatexCache() {
        latexCached.removeAllValues()
    }
    
    // MARK: - AttributedText Cache
    
    public func setAttributedTextCache(_ text: NSAttributedString, for key: String) {
        attributedCached.setValue(text, forKey: key.cacheKey)
    }
    
    public func getAttributedTextCache(for key: String) -> NSAttributedString? {
        return attributedCached.value(forKey: key.cacheKey)
    }
    
    public func clearAttributedTextCache() {
        attributedCached.removeAllValues()
    }
    
    // MARK: - Clean All
    
    public func clearAllCache() {
        clearLatexCache()
        clearAttributedTextCache()
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
    
    func trimmed() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var cacheKey: String {
        let trimmedKey = self.trimmed()
        guard !trimmedKey.isEmpty else { return UUID().uuidString }
        // 使用 MD5 哈希生成唯一的缓存键
        return trimmedKey.md5()
    }
}
