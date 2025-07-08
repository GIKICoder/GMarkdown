//
//  FontExts.swift
//  GMarkdown
//
//  Created by GIKI on 2025/7/7.
//

import UIKit

// MARK: - Helper Extensions

extension UIFont {
    var italic: UIFont? {
        return apply(newTraits: .traitItalic)
    }
    
    var bold: UIFont? {
        return apply(newTraits: .traitBold)
    }
    
    func apply(newTraits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        var existingTraits = self.fontDescriptor.symbolicTraits
        existingTraits.insert(newTraits)
        
        guard let newDescriptor = self.fontDescriptor.withSymbolicTraits(existingTraits) else { return nil }
        return UIFont(descriptor: newDescriptor, size: self.pointSize)
    }
}
