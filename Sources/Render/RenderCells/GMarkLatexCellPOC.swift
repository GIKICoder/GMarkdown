//
//  File.swift
//  GMarkdown
//
//  Created by GIKI on 2025/3/14.
//
import Foundation
import UIKit
import MPITextKit

/*
// MARK: - SVG渲染队列管理器
class SVGRenderQueueManager {
    static let shared = SVGRenderQueueManager()
    
    private var pendingTasks = [String: RenderTask]()
    private let taskLock = NSLock()
    private var renderTimer: Timer?
    private let maxBatchSize = 3 // 每批最多处理的任务数
    
    private init() {}
    
    // 渲染任务结构
    struct RenderTask {
        let key: String
        let node: Node // Macaw 的 Node 类型
        let size: CGSize
        let scale: CGFloat
        let completion: (UIImage?) -> Void
    }
    
    // 添加渲染任务
    func addRenderTask(_ task: RenderTask) {
        taskLock.lock()
        defer { taskLock.unlock() }
        
        // 检查缓存
        if let cachedImage = GMarkCachedManager.shared.getLatexCache(for: task.key) {
            DispatchQueue.main.async {
                task.completion(cachedImage)
            }
            return
        }
        
        // 添加到待处理任务
        pendingTasks[task.key] = task
        
        // 启动渲染定时器
        DispatchQueue.main.async { [weak self] in
            self?.startRenderTimerIfNeeded()
        }
    }
    
    // 取消特定任务
    func cancelTask(withKey key: String) {
        taskLock.lock()
        pendingTasks.removeValue(forKey: key)
        taskLock.unlock()
    }
    
    // 取消所有任务
    func cancelAllTasks() {
        taskLock.lock()
        pendingTasks.removeAll()
        taskLock.unlock()
        
        DispatchQueue.main.async { [weak self] in
            self?.stopRenderTimer()
        }
    }
    
    // MARK: - Private Methods
    
    private func startRenderTimerIfNeeded() {
        guard renderTimer == nil else { return }
        
        // 使用 Timer 分批处理任务，避免阻塞主线程
        renderTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.processNextBatch()
        }
    }
    
    private func stopRenderTimer() {
        renderTimer?.invalidate()
        renderTimer = nil
    }
    
    private func processNextBatch() {
        taskLock.lock()
        
        // 获取下一批任务
        let tasksToProcess = Array(pendingTasks.prefix(maxBatchSize))
        tasksToProcess.forEach { pendingTasks.removeValue(forKey: $0.key) }
        
        // 如果没有更多任务，停止定时器
        if pendingTasks.isEmpty {
            taskLock.unlock()
            stopRenderTimer()
            return
        }
        
        taskLock.unlock()
        
        // 在主线程渲染
        tasksToProcess.forEach { (_, task) in
            renderTask(task)
        }
    }
    
    private func renderTask(_ task: RenderTask) {
        // 创建 SVGView
        let svgView = SVGView(node: task.node, frame: CGRect(origin: .zero, size: task.size))
        svgView.backgroundColor = .clear
        
        // 开始图形上下文
        UIGraphicsBeginImageContextWithOptions(task.size, false, task.scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            task.completion(nil)
            return
        }
        
        // 渲染到上下文
        svgView.layer.render(in: context)
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 异步缓存图片
        if let image = renderedImage {
            DispatchQueue.global(qos: .background).async {
                GMarkCachedManager.shared.setLatexCache(image, for: task.key)
            }
        }
        
        // 完成回调
        task.completion(renderedImage)
    }
}

// MARK: - GMarkLatexCell
class GMarkLatexCellPOC: UICollectionViewCell, ChunkCellConfigurable {
    static let reuseIdentifier = "GMarkLatexCellPOC"
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    
    private let latexImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var svgView: SVGView?
    private var currentRenderKey: String?
    
    // MARK: - Lifecycle
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required public init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = contentView.bounds
        loadingIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 取消之前的渲染任务
        if let renderKey = currentRenderKey {
            SVGRenderQueueManager.shared.cancelTask(withKey: renderKey)
            currentRenderKey = nil
        }
        
        // 清理视图
        latexImageView.image = nil
        latexImageView.isHidden = true
        svgView?.removeFromSuperview()
        svgView = nil
        loadingIndicator.stopAnimating()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(scrollView)
        scrollView.addSubview(latexImageView)
        contentView.addSubview(loadingIndicator)
        
        // 设置背景色
        contentView.backgroundColor = .systemBackground
        scrollView.backgroundColor = .clear
    }
    
    // MARK: - Configuration
    
    func configure(with chunk: GMarkChunk) {
        // 如果已经有渲染好的图片，直接显示
        if let image = chunk.latexImage {
            displayLatexImage(image, chunk: chunk)
            return
        }
        
        // 如果有 LaTeX 节点，进行异步渲染
        guard let node = chunk.latexNode else { return }
        
        // 隐藏图片视图，显示加载状态
        latexImageView.isHidden = true
        svgView?.removeFromSuperview()
        svgView = nil
        
        // 计算 frame
        let frame = calculateFrame(for: chunk)
        
        // 生成渲染任务的 key
        let renderKey = chunk.latexKey ?? chunk.attributedText.string
        currentRenderKey = renderKey
        
        // 检查缓存
        if let cachedImage = GMarkCachedManager.shared.getLatexCache(for: renderKey) {
            displayLatexImage(cachedImage, chunk: chunk)
            chunk.latexImage = cachedImage
            return
        }
        
        // 显示加载状态
        loadingIndicator.startAnimating()
        
        // 创建渲染任务
        let task = SVGRenderQueueManager.RenderTask(
            key: renderKey,
            node: node,
            size: frame.size,
            scale: UIScreen.main.scale
        ) { [weak self] renderedImage in
            guard let self = self else { return }
            
            // 确保这个 cell 仍然显示相同的内容
            guard self.currentRenderKey == renderKey else { return }
            
            // 停止加载动画
            self.loadingIndicator.stopAnimating()
            
            // 显示渲染结果
            if let image = renderedImage {
                self.displayLatexImage(image, chunk: chunk)
                
                // 更新 chunk 的缓存图片
                chunk.latexImage = image
            }
        }
        
        // 添加到渲染队列
        SVGRenderQueueManager.shared.addRenderTask(task)
    }
    
    // MARK: - Private Methods
    
    private func calculateFrame(for chunk: GMarkChunk) -> CGRect {
        var frame = CGRect(
            x: 0,
            y: chunk.style.codeBlockStyle.padding.top,
            width: chunk.latexSize.width,
            height: chunk.latexSize.height
        )
        
        if chunk.latexSize.width < scrollView.frame.width {
            let left = (scrollView.frame.width - chunk.latexSize.width) * 0.5
            frame.origin.x = left
        }
        
        return frame
    }
    
    private func displayLatexImage(_ image: UIImage, chunk: GMarkChunk) {
        latexImageView.isHidden = false
        latexImageView.image = image
        
        let padding = chunk.style.codeBlockStyle.padding
        
        if image.size.width >= scrollView.frame.width {
            latexImageView.frame = CGRect(
                x: 0,
                y: padding.top,
                width: image.size.width,
                height: image.size.height
            )
        } else {
            let left = (scrollView.frame.width - image.size.width) * 0.5
            latexImageView.frame = CGRect(
                x: left,
                y: padding.top,
                width: image.size.width,
                height: image.size.height
            )
        }
        
        scrollView.contentSize = CGSize(
            width: max(image.size.width, scrollView.frame.width),
            height: image.size.height + padding.top + padding.bottom
        )
    }
}

// MARK: - 预渲染扩展
extension GMarkLatexCell {
    /// 预渲染 LaTeX 内容
    static func preRenderLatex(for chunks: [GMarkChunk], priority: Bool = false) {
        chunks.forEach { chunk in
            guard let node = chunk.latexNode else { return }
            
            let renderKey = chunk.latexKey ?? chunk.attributedText.string
            
            // 已有缓存则跳过
            if GMarkCachedManager.shared.getLatexCache(for: renderKey) != nil {
                return
            }
            
            let size = CGSize(
                width: chunk.latexSize.width,
                height: chunk.latexSize.height
            )
            
            let task = SVGRenderQueueManager.RenderTask(
                key: renderKey,
                node: node,
                size: size,
                scale: UIScreen.main.scale
            ) { image in
                if let image = image {
                    chunk.latexImage = image
                }
            }
            
            SVGRenderQueueManager.shared.addRenderTask(task)
        }
    }
}

// MARK: - 性能优化扩展
extension SVGRenderQueueManager {
    /// 暂停渲染（用于滚动时）
    func pauseRendering() {
        DispatchQueue.main.async { [weak self] in
            self?.renderTimer?.invalidate()
            self?.renderTimer = nil
        }
    }
    
    /// 恢复渲染
    func resumeRendering() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.taskLock.lock()
            let hasTasks = !self.pendingTasks.isEmpty
            self.taskLock.unlock()
            
            if hasTasks {
                self.startRenderTimerIfNeeded()
            }
        }
    }
}

*/

// MARK: - 使用示例
/*
// 在 UICollectionView 的代理方法中使用
func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    SVGRenderQueueManager.shared.pauseRendering()
}

func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
        SVGRenderQueueManager.shared.resumeRendering()
    }
}

func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    SVGRenderQueueManager.shared.resumeRendering()
    
    // 预渲染可见范围附近的内容
    let visibleIndexPaths = collectionView.indexPathsForVisibleItems
    var chunksToPreload: [GMarkChunk] = []
    
    for indexPath in visibleIndexPaths {
        let range = max(0, indexPath.item - 3)...min(chunks.count - 1, indexPath.item + 3)
        chunksToPreload.append(contentsOf: chunks[range].filter { $0.latexNode != nil })
    }
    
    GMarkLatexCell.preRenderLatex(for: chunksToPreload)
}
*/
