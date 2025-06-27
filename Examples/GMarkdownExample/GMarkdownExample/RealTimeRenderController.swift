//
//  StreamRenderController.swift
//  GMarkdownExample
//
//  Created by GIKI on 2025/6/28.
//

import UIKit
import GMarkdown

class RealTimeRenderController: UIViewController {
    
    private let markdownView = GMarkdownMultiView()
    private let imageloader = NukeImageLoader()
    private let menuButton = UIButton(type: .system)
    private let streamButton = UIButton(type: .system)
    private let containerView = UIView()
    private var currentMarkdownFile = "markdown"
    private var displayLink: CADisplayLink?
    private var currentIndex = 0
    private var currentContent = ""
    
    private let markdownFiles = ["markdown", "markdownv2", "markdownv3", "markdownv4", "markdownv5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        Task {
            await loadMarkdown(fileName: currentMarkdownFile)
        }
    }
    
    deinit {
        GMarkCachedManager.shared.clearAllCache()
        stopDisplayLink()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.1
        view.addSubview(containerView)
        
        markdownView.backgroundColor = .systemBackground
        containerView.addSubview(markdownView)
        
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
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        markdownView.translatesAutoresizingMaskIntoConstraints = false
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        streamButton.translatesAutoresizingMaskIntoConstraints = false
        
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
            menuButton.heightAnchor.constraint(equalToConstant: 40),
            
            streamButton.topAnchor.constraint(equalTo: menuButton.bottomAnchor, constant: 16),
            streamButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            streamButton.widthAnchor.constraint(equalToConstant: 40),
            streamButton.heightAnchor.constraint(equalToConstant: 40)
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
            // 提高渲染频率，设置更高的帧率范围以实现更快的更新
            displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120)
        } else {
            // 在旧版本iOS上设置更短的帧间隔以提高更新频率
            displayLink?.frameInterval = 1  // 每帧都更新，即60fps
        }
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
        GMarkCachedManager.shared.clearAllCache()
    }
    
    @objc private func updateStreamContent() {
        guard currentIndex < currentContent.count else {
            stopDisplayLink()
            return
        }
        
        // 随机读取1-5个字符，模拟SSE实时流效果
        let randomCharCount = Int.random(in: 1...5)
        let endIndex = min(currentIndex + randomCharCount, currentContent.count)
        let partialContent = String(currentContent.prefix(endIndex))
        currentIndex = endIndex
        
        Task { [weak self] in
             guard let self = self else { return }
             let chunks = await parseMarkdown(partialContent)
             await MainActor.run {
                 self.markdownView.updateMarkdown(chunks)
             }
         }
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
                let style = MarkdownStyle.defaultStyle()
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
