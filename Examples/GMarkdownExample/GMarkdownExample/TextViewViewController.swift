//
//  TextViewViewController.swift
//  GMarkdownExample
//
//  Created by GIKI on 2025/2/8.
//

import UIKit
import GMarkdown

class TextViewViewController: UIViewController {
    
    let markdownView = MarkdownTextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        markdownView.isEditable = false
        markdownView.isScrollEnabled = true
        markdownView.isSelectable = true
        view.addSubview(markdownView)
        
        markdownView.frame = view.bounds
        
        setupMarkdown()
    }
    
    @MainActor
    func setupMarkdown() {
        guard let filepath = Bundle.main.path(forResource: "markdown", ofType: nil),
              let filecontents = try? String(contentsOfFile: filepath, encoding: .utf8) else {
            return
        }
        
        let document = GMarkParser().parseMarkdown(from: filecontents)
        var style = MarkdownStyle.defaultStyle()
        style.useMPTextKit = false
        style.codeBlockStyle.customRender = false
        var vistor = GMarkupAttachVisitor(style: style)
        let attributedText = vistor.visit(document)
        self.markdownView.attributedText = attributedText
        let height = attributedText.height(withWidth: style.maxContainerWidth)
        print("Calculated height: \(height)")
    }

}

extension NSAttributedString {
    
    /// 计算富文本在指定宽度下的高度
    /// - Parameter width: 限制宽度
    /// - Returns: 计算出的高度
    func height(withWidth width: CGFloat) -> CGFloat {
        return height(withConstrainedSize: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
    }
    
    /// 计算富文本在指定尺寸约束下的高度
    /// - Parameter size: 限制尺寸
    /// - Returns: 计算出的高度
    func height(withConstrainedSize size: CGSize) -> CGFloat {
        let actualSize = self.size(withConstrainedSize: size)
        return actualSize.height
    }
    
    /// 计算富文本的实际尺寸
    /// - Parameter width: 限制宽度
    /// - Returns: 实际尺寸
    func size(withWidth width: CGFloat) -> CGSize {
        return size(withConstrainedSize: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
    }
    
    /// 计算富文本在指定约束下的实际尺寸
    /// - Parameter size: 约束尺寸
    /// - Returns: 实际尺寸
    func size(withConstrainedSize size: CGSize) -> CGSize {
        guard self.length > 0 else {
            return CGSize.zero
        }
        
        let rect = self.boundingRect(
            with: size,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        // 向上取整，避免显示不全
        return CGSize(width: ceil(rect.size.width), height: ceil(rect.size.height))
    }
}
