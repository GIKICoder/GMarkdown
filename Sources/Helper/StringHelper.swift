//
//  StringHelper.swift
//  GMarkdown
//
//  Created by GIKI on 2025/6/28.
//

import CryptoKit
import UIKit


// MARK: - Extensions

extension Data {
    /// Computes the MD5 hash of the data.
    ///
    /// - Returns: A hexadecimal string representation of the MD5 hash.
    func md5Hash() -> String {
        let digest = Insecure.MD5.hash(data: self)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}

extension String {
    
    var cacheKey: String {
        let trimmedKey = self.trimmed()
        guard !trimmedKey.isEmpty else { return UUID().uuidString }
        // 使用 MD5 哈希生成唯一的缓存键
        return trimmedKey.md5()
    }
    
    /// Computes the MD5 hash of the string.
    ///
    /// - Returns: A hexadecimal string representation of the MD5 hash.
    func md5() -> String {
        self.data(using: .utf8)?.md5Hash() ?? ""
    }
    
    func trimmed() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
   
}
