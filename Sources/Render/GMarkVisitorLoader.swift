//
//  GMarkPluginManager.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/29.
//

import Foundation
import UIKit

// ImageLoader
public protocol ImageLoader {
    func loadImage(from source: String, into imageView: UIImageView)
    func download(from source: String) async -> UIImage?
}

public protocol ReferLoader {
    func referQuote(from source: String, style: Style) -> NSAttributedString
    func referQuoteLink(from source: String) -> String?
    func referQuoteWebSite(from source: String) -> String?
    func referImage(from source: String, style: Style) -> NSAttributedString
}

