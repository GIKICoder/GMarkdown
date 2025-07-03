//
//  TextDirectionDetector.swift
//  GMarkdown
//
//  Created by 巩柯 on 2025/7/3.
//

import Foundation

public struct TextDirectionDetector {
    
    public static func isRTLLanguage(text: String) -> Bool {
        // 辅助函数，判断字符是否为数字或符号
        func isNumberOrSymbol(_ character: Character) -> Bool {
            return character.isNumber || character.isPunctuation || character.isSymbol || character.isWhitespace
        }
        
        // 遍历文本中的字符，跳过所有前导的数字和符号
        for character in text {
            if isNumberOrSymbol(character) {
                continue
            }
            // 找到第一个非数字且非符号的字符，进行RTL判断
            if let firstScalar = character.unicodeScalars.first {
                let codePoint = firstScalar.value
                // 阿拉伯语和希伯来语的Unicode范围
                switch codePoint {
                case 0x0590...0x08FF,   // 包含希伯来语、阿拉伯语等
                     0xFB1D...0xFDFF,
                     0xFE70...0xFEFF,
                     0x1EE00...0x1EEFF:
                    return true
                default:
                    return false
                }
            }
        }
        
        // 如果文本为空或未检测到RTL字符，可以根据系统语言或其他逻辑决定
        let language = Locale.current.languageCode ?? "en"
        let rtlLanguages = ["ar", "he", "fa", "ur"] // 常见的RTL语言
        return rtlLanguages.contains(language)
    }
}
