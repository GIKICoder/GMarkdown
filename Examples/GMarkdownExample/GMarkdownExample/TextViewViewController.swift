//
//  TextViewViewController.swift
//  GMarkdownExample
//
//  Created by GIKI on 2025/2/8.
//

import UIKit
import GMarkdown

class TextViewViewController: UIViewController {
    
    private let markdownView = MarkdownTextView()
    private let menuButton = UIButton(type: .system)
    private let streamButton = UIButton(type: .system)
    private var currentMarkdownFile = "markdown"
    private var displayLink: CADisplayLink?
    private var currentIndex = 0
    private var currentContent = ""
    
    private let markdownFiles = ["markdown", "markdownv2", "markdownv3", "markdownv4", "markdownv5","markdownLatex","markdownTemp"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMarkdown()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        markdownView.isEditable = false
        markdownView.isScrollEnabled = true
        markdownView.isSelectable = true
        view.addSubview(markdownView)
        
        menuButton.setImage(UIImage(systemName: "text.book.closed"), for: .normal)
        menuButton.backgroundColor = .systemBackground
        menuButton.layer.cornerRadius = 20
        menuButton.layer.shadowColor = UIColor.black.cgColor
        menuButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        menuButton.layer.shadowRadius = 4
        menuButton.layer.shadowOpacity = 0.1
        menuButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        view.addSubview(menuButton)
        
        streamButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        streamButton.backgroundColor = .systemBackground
        streamButton.layer.cornerRadius = 20
        streamButton.layer.shadowColor = UIColor.black.cgColor
        streamButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        streamButton.layer.shadowRadius = 4
        streamButton.layer.shadowOpacity = 0.1
        streamButton.addTarget(self, action: #selector(startStreamRendering), for: .touchUpInside)
        view.addSubview(streamButton)
        
        markdownView.translatesAutoresizingMaskIntoConstraints = false
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        streamButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            markdownView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            markdownView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            markdownView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            markdownView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            menuButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            menuButton.widthAnchor.constraint(equalToConstant: 40),
            menuButton.heightAnchor.constraint(equalToConstant: 40),
            
            streamButton.topAnchor.constraint(equalTo: menuButton.bottomAnchor, constant: 16),
            streamButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            streamButton.widthAnchor.constraint(equalToConstant: 40),
            streamButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @MainActor
    private func setupMarkdown() {
        Task {
            await loadMarkdown(fileName: currentMarkdownFile)
        }
    }
    
    @objc private func showMenu() {
        let alert = UIAlertController(title: "选择Markdown文件", message: nil, preferredStyle: .actionSheet)
        
        for file in markdownFiles {
            let action = UIAlertAction(title: file, style: .default) { [weak self] _ in
                self?.currentMarkdownFile = file
                Task { [weak self] in
                    await self?.loadMarkdown(fileName: file)
                }
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = menuButton
            popover.sourceRect = menuButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    @objc private func startStreamRendering() {
        stopDisplayLink()
        currentIndex = 0
        
        Task { [weak self] in
            guard let self = self,
                  let filepath = Bundle.main.path(forResource: currentMarkdownFile, ofType: nil),
                  let filecontents = try? String(contentsOfFile: filepath, encoding: .utf8) else {
                return
            }
            self.currentContent = filecontents
            self.setupDisplayLink()
        }
    }
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateStreamContent))
        if #available(iOS 15.0, *) {
            displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120)
        } else {
            displayLink?.frameInterval = 1
        }
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateStreamContent() {
        guard currentIndex < currentContent.count else {
            stopDisplayLink()
            return
        }
        
        let randomCharCount = Int.random(in: 1...5)
        let endIndex = min(currentIndex + randomCharCount, currentContent.count)
        let partialContent = String(currentContent.prefix(endIndex))
        currentIndex = endIndex
        
        Task { [weak self] in
            guard let self = self else { return }
            await self.renderMarkdown(partialContent)
        }
    }
    
    private func loadMarkdown(fileName: String) async {
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: nil),
              let filecontents = try? String(contentsOfFile: filepath, encoding: .utf8) else {
            return
        }
        
        await renderMarkdown(filecontents)
        self.title = fileName
    }
    
    private func renderMarkdown(_ content: String) async {
        let document = GMarkParser().parseMarkdown(from: content)
        var style = MarkdownStyle.defaultStyle()
        style.useMPTextKit = false
        style.codeBlockStyle.customRender = false
        style.maxContainerWidth = view.bounds.width - 32
        var visitor = GMarkupAttachVisitor(style: style)
        visitor.imageLoader = NukeImageLoader()
        let attributedText = visitor.visit(document)
        let height = attributedText.height(withWidth: style.maxContainerWidth)
        print("Markdown content height: \(height)")
        await MainActor.run {
            self.markdownView.attributedText = attributedText
        }
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
