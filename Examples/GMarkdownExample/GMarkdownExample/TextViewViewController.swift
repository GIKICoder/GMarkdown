//
//  TextViewViewController.swift
//  GMarkdownExample
//
//  Created by GIKI on 2025/2/8.
//

import UIKit

class TextViewViewController: UIViewController {
    
    let markdownView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        GMarkPluginManager.shared.imageLoader = NukeImageLoader()
        markdownView.isEditable = false
        markdownView.isScrollEnabled = true
        markdownView.isSelectable = true
        view.addSubview(markdownView)
        
        markdownView.frame = CGRectMake(10, 100, UIScreen.main.bounds.width-20, 300)
        
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
        var vistor = GMarkupVisitor(style: style)
        let attributedText = vistor.visit(document)
        self.markdownView.attributedText = attributedText
    }

}
