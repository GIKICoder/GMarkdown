//
//  GMarkTableRender.swift
//  GMarkRender
//
//  Created by GIKI on 2025/04/27.
//

import Foundation
import Markdown
import MPITextKit
import UIKit
import CryptoKit

// MARK: - GMarkTableRender

/// A class responsible for rendering a parsed Markdown table with various attributes.
/// It processes headers and body content to generate text renderers and calculates the table's height.
public final class GMarkTableRender {
    
    // MARK: - Properties
    
    /// The Markdown table to be rendered.
    public let markTable: GMarkTable
    
    /// The style applied to the table.
    public let style: Style
    
    /// Renderers for the table headers.
    public var headerRenders: [MPITextRenderer] = []
    
    /// Renderers for the table body rows.
    public var bodyRenders: [[MPITextRenderer]] = []
    
    /// The calculated height of the table.
    public var tableHeight: CGFloat = 0
    
    // MARK: - Initializers
    
    /// Initializes a new `GMarkTableRender` with the provided Markdown table and style.
    ///
    /// - Parameters:
    ///   - markTable: The Markdown table to be rendered.
    ///   - style: The style to apply to the table.
    public init(markTable: GMarkTable, style: Style) {
        self.markTable = markTable
        self.style = style
        setupTableRender()
    }
    
    
    // MARK: - Public Methods
    
    /// Refreshes the table renderers and recalculates the table height.
    public func refreshRender() {
        // Clear existing renderers and reset height
        headerRenders = []
        bodyRenders = []
        tableHeight = 0
        
        setupTableRender()
    }
    
    // MARK: - Private Methods
    
    /// Sets up the table renderers for headers and body, and calculates the total table height.
    private func setupTableRender() {
        let maxWidth = style.tableStyle.cellMaximumWidth
        let defaultHeight = style.tableStyle.cellHeight
        let paddingHeight = style.tableStyle.cellPadding.top + style.tableStyle.cellPadding.bottom
        var totalHeight = defaultHeight
        
        // Setup header renderers
        markTable.headers?.forEach { header in
            let renderer = createTextRenderer(from: header, maxWidth: maxWidth)
            headerRenders.append(renderer)
            totalHeight = max(renderer.size().height + paddingHeight, totalHeight)
        }
        
        // Setup body renderers
        markTable.bodys?.forEach { row in
            var rowRenderers: [MPITextRenderer] = []
            var maxRowHeight = defaultHeight
            for cell in row {
                let renderer = createTextRenderer(from: cell, maxWidth: maxWidth)
                rowRenderers.append(renderer)
                maxRowHeight = max(renderer.size().height + paddingHeight, maxRowHeight)
            }
            bodyRenders.append(rowRenderers)
            totalHeight += maxRowHeight
        }
        
        // Add padding to the total height
        totalHeight += style.tableStyle.padding.top + style.tableStyle.padding.bottom
        tableHeight = totalHeight
    }
    
    /// Creates an `MPITextRenderer` for the given attributed string and maximum width.
    ///
    /// - Parameters:
    ///   - attributedText: The attributed string to render.
    ///   - maxWidth: The maximum width available for rendering.
    /// - Returns: A configured `MPITextRenderer` instance.
    private func createTextRenderer(from attributedText: NSAttributedString, maxWidth: CGFloat) -> MPITextRenderer {
        let builder = MPITextRenderAttributesBuilder()
        builder.attributedText = attributedText
        builder.maximumNumberOfLines = UInt(style.tableStyle.maximumNumberOfLines)
        let renderAttributes = MPITextRenderAttributes(builder: builder)
        let constrainedSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        return MPITextRenderer(renderAttributes: renderAttributes, constrainedSize: constrainedSize)
    }
}
