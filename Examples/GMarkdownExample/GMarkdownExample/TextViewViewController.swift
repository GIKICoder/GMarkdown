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
    }

}
