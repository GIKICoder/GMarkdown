//
//  GMarkCachedManager.swift
//  GMarkdown
//
//  Created by 巩柯 on 2025/6/28.
//

import Foundation
import UIKit

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
    

