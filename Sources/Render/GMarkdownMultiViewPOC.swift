//
//  GMarkdownMultiView.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/25.
//

import Markdown
import MPITextKit
import UIKit

/*

public class GMarkdownMultiViewPOC: UIView {
    // MARK: - Properties
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, GMarkChunk>!
    private var chunks: [GMarkChunk] = []
    
    public var handlerChain: GMarkHandlerChain = .init()
    
    // 滚动优化相关属性
    private var isScrolling = false
    private var preloadRange = 3 // 预加载前后3个cell
    
    // 配置项
    public var enableScrollOptimization = true
    public var enablePreloading = true
    
    // MARK: - Initialization
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addHandlers()
        setupCollectionView()
        configureDataSource()
    }
    
    // MARK: - Setup
    
    private func setupCollectionView() {
        let layout = createLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        configureCollectionView()
        addCollectionViewConstraints()
        registerCells()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }
    
    private func configureCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = false
        collectionView.delegate = self
        addSubview(collectionView)
    }
    
    private func addCollectionViewConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func registerCells() {
        collectionView.registerCells(ChunkCellProviderFactory.allProviders)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, GMarkChunk>(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            let provider = ChunkCellProviderFactory.provider(for: item)
            let cell = provider.dequeueConfiguredCell(for: collectionView, at: indexPath, with: item)
            self?.configureHandlerChain(for: cell)
            return cell
        }
    }
    
    private func configureHandlerChain(for cell: UICollectionViewCell) {
        if let textCell = cell as? GMarkTextCell {
            textCell.handlerChain = handlerChain
        } else if let codeCell = cell as? GMarkCodeCell {
            codeCell.handlerChain = handlerChain
        } else if let tableCell = cell as? GMarkTableCell {
            tableCell.handlerChain = handlerChain
        }
    }
    
    // MARK: - Public Methods
    
    public func updateMarkdown(_ items: [GMarkChunk]) {
        self.chunks = items
        var snapshot = NSDiffableDataSourceSnapshot<Section, GMarkChunk>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            // 初始预加载
            self?.preloadVisibleLatex()
        }
    }
    
    // MARK: - Preloading Methods
    
    private func preloadVisibleLatex() {
        guard enablePreloading else { return }
        
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        var chunksToPreload: [GMarkChunk] = []
        
        for indexPath in visibleIndexPaths {
            let start = max(0, indexPath.item - preloadRange)
            let end = min(chunks.count - 1, indexPath.item + preloadRange)
            
            for i in start...end {
                if let chunk = chunks[safe: i] {
                    chunksToPreload.append(chunk)
                }
            }
        }
        
        // 去重
        let uniqueChunks = Array(Set(chunksToPreload))
        
        if !uniqueChunks.isEmpty {
            GMarkLatexCell.preRenderLatex(for: uniqueChunks)
        }
    }
    
    // MARK: - Public Configuration Methods
    
    /// 设置是否启用滚动优化
    public func setScrollOptimization(enabled: Bool) {
        enableScrollOptimization = enabled
    }
    
    /// 设置是否启用预加载
    public func setPreloading(enabled: Bool) {
        enablePreloading = enabled
    }
    
    /// 设置预加载范围
    public func setPreloadRange(_ range: Int) {
        let mutableSelf = self
        mutableSelf.preloadRange = max(1, range)
    }
    
    /// 手动触发预加载
    public func triggerPreload() {
        preloadVisibleLatex()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GMarkdownMultiViewPOC: UICollectionViewDelegateFlowLayout {
    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return CGSize(width: UIScreen.main.bounds.width, height: 0.00)
        }
        
        let width = min(item.style.maxContainerWidth, UIScreen.main.bounds.width)
        return CGSize(width: width, height: item.itemSize.height)
    }
}

// MARK: - UIScrollViewDelegate (滚动优化)

extension GMarkdownMultiViewPOC {
    // 开始拖拽时暂停渲染
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard enableScrollOptimization else { return }
        
        isScrolling = true
        SVGRenderQueueManager.shared.pauseRendering()
    }
    
    // 结束拖拽时根据情况恢复渲染
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard enableScrollOptimization else { return }
        
        if !decelerate {
            // 没有减速，立即恢复渲染
            isScrolling = false
            SVGRenderQueueManager.shared.resumeRendering()
            
            // 延迟一点时间再预加载，让当前可见的内容先渲染
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.preloadVisibleLatex()
            }
        }
    }
    
    // 减速结束时恢复渲染
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard enableScrollOptimization else { return }
        
        isScrolling = false
        SVGRenderQueueManager.shared.resumeRendering()
        
        // 预渲染可见范围附近的内容
        preloadVisibleLatex()
    }
    
    // 快速滚动时的优化
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard enableScrollOptimization else { return }
        
        // 如果正在快速滚动，确保渲染是暂停的
        if isScrolling && abs(scrollView.contentOffset.y) > 50 {
            SVGRenderQueueManager.shared.pauseRendering()
        }
    }
    
    // 程序化滚动结束
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard enableScrollOptimization else { return }
        
        isScrolling = false
        SVGRenderQueueManager.shared.resumeRendering()
        preloadVisibleLatex()
    }
}

// MARK: - Handler Management

extension GMarkdownMultiViewPOC {
    func addHandlers() {
        let handler = DefaultMarkHandler()
        handlerChain.addHandler(handler)
    }
}

// MARK: - Public API Extensions

public extension GMarkdownMultiViewPOC {
    /// 清除所有渲染任务
    func clearRenderingQueue() {
        SVGRenderQueueManager.shared.cancelAllTasks()
    }
    
    /// 获取当前渲染状态
    var isRendering: Bool {
        return !isScrolling
    }
}
*/
