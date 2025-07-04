//
//  MarkdownRenderController.swift
//  GMarkdownExample
//
//  Created by GIKI on 2024/8/1.
//

import UIKit
import GMarkdown

class MarkdownRenderController: UIViewController {
    
    private let markdownView = GMarkdownMultiView()
    private let imageloader = NukeImageLoader()
    private let menuButton = UIButton(type: .system)
    private let containerView = UIView()
    private var currentMarkdownFile = "markdown"
    
    private let markdownFiles = ["markdown", "markdownv2", "markdownv3", "markdownv4", "markdownv5","markdownLatex","markdownLatex2"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        Task {
            await loadMarkdown(fileName: currentMarkdownFile)
        }
    }
    deinit {
        GMarkCachedManager.shared.clearAllCache()
    }
    
    private func setupUI() {
        // 设置容器视图
        view.backgroundColor = .systemBackground
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.1
        view.addSubview(containerView)
        
        // 设置Markdown视图
        markdownView.backgroundColor = .systemBackground
        containerView.addSubview(markdownView)
        
        // 设置菜单按钮
        menuButton.setImage(UIImage(systemName: "text.book.closed"), for: .normal)
        menuButton.backgroundColor = .systemBackground
        menuButton.layer.cornerRadius = 20
        menuButton.layer.shadowColor = UIColor.black.cgColor
        menuButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        menuButton.layer.shadowRadius = 4
        menuButton.layer.shadowOpacity = 0.1
        menuButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        view.addSubview(menuButton)
        
        // 设置约束
        containerView.translatesAutoresizingMaskIntoConstraints = false
        markdownView.translatesAutoresizingMaskIntoConstraints = false
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            
            markdownView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            markdownView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            markdownView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            markdownView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            menuButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            menuButton.widthAnchor.constraint(equalToConstant: 40),
            menuButton.heightAnchor.constraint(equalToConstant: 40)
        ])
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
    
    
    private func loadMarkdown(fileName: String) async {
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: nil),
              let filecontents = try? String(contentsOfFile: filepath, encoding: .utf8) else {
            return
        }
        
        let chunks = await parseMarkdown(filecontents)
        
        await MainActor.run { [weak self] in
            self?.markdownView.updateMarkdown(chunks)
            self?.title = fileName
        }
    }
    
    private func parseMarkdown(_ content: String) async -> [GMarkChunk] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var style = MarkdownStyle.defaultStyle()
                style.maxContainerWidth = UIScreen.main.bounds.size.width - 32*2
                let generator = GMarkChunkGenerator()
                generator.style = style
                generator.imageLoader = self.imageloader
                generator.addLaTexHandler()
                let processor = GMarkProcessor(parser: GMarkParser(), chunkGenerator: generator)
                let chunks = processor.process(markdown: content)
                continuation.resume(returning: chunks)
            }
        }
    }
}
