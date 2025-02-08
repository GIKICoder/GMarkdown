//
//  GMarkdownMultiView.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/25.
//

import Markdown
import MPITextKit
import UIKit

// MARK: - Protocols

protocol ChunkCellConfigurable {
    func configure(with chunk: GMarkChunk)
}

protocol ChunkCellProvider {
    static var cellClass: AnyClass { get }
    static var reuseIdentifier: String { get }
    func dequeueConfiguredCell(for collectionView: UICollectionView, at indexPath: IndexPath, with chunk: GMarkChunk) -> UICollectionViewCell
}

// MARK: - ChunkCellProvider Implementation

struct DefaultChunkCellProvider<T: UICollectionViewCell & ChunkCellConfigurable>: ChunkCellProvider {
    static var cellClass: AnyClass { T.self }
    static var reuseIdentifier: String { String(describing: T.self) }

    func dequeueConfiguredCell(for collectionView: UICollectionView, at indexPath: IndexPath, with chunk: GMarkChunk) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.reuseIdentifier, for: indexPath) as! T
        cell.configure(with: chunk)
        return cell
    }
}

extension ChunkCellConfigurable {
    func configure(with _: GMarkChunk) {}
}

// MARK: - CellProvider Factory

class ChunkCellProviderFactory {
    static func provider(for chunkType: ChunkType) -> ChunkCellProvider {
        switch chunkType {
        case .Text:
            return DefaultChunkCellProvider<GMarkTextCell>()
        case .Code:
            return DefaultChunkCellProvider<GMarkCodeCell>()
        case .Table:
            return DefaultChunkCellProvider<GMarkTableCell>()
        case .Thematic:
            return DefaultChunkCellProvider<GMarkThematicCell>()
        default:
            return DefaultChunkCellProvider<GMarkTextCell>()
        }
    }

    static var allProviders: [ChunkCellProvider.Type] {
        return [
            DefaultChunkCellProvider<GMarkTextCell>.self,
            DefaultChunkCellProvider<GMarkCodeCell>.self,
            DefaultChunkCellProvider<GMarkTableCell>.self,
            DefaultChunkCellProvider<GMarkThematicCell>.self,
        ]
    }
}

// MARK: - UICollectionView Extension

extension UICollectionView {
    func registerCells(_ providers: [ChunkCellProvider.Type]) {
        for provider in providers {
            register(provider.cellClass, forCellWithReuseIdentifier: provider.reuseIdentifier)
        }
    }
}

class GMarkdownMultiView: UIView {
    // MARK: - Properties

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, GMarkChunk>!

    public var handlerChain: GMarkHandlerChain = .init()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
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
        collectionView.backgroundColor = .white
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
            let provider = ChunkCellProviderFactory.provider(for: item.chunkType)
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

    func updateMarkdown(_ items: [GMarkChunk]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, GMarkChunk>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension GMarkdownMultiView: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return CGSize(width: UIScreen.main.bounds.width, height: 0.00)
        }

        let width = min(item.style.maxContainerWidth, UIScreen.main.bounds.width)
        return CGSize(width: width, height: item.itemSize.height)
    }
}

extension GMarkdownMultiView {
    func addHandlers() {
        let handler = DefaultMarkHandler()
        handlerChain.addHandler(handler)
    }
}

// MARK: - Supporting Types

enum Section {
    case main
}

class GMarkTextCell: UICollectionViewCell, MPILabelDelegate, ChunkCellConfigurable {
    public var handlerChain: GMarkHandlerChain?

    static let reuseIdentifier = "GMarkTextCell"

    private let label: MPILabel = {
        let label = MPILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.delegate = self
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -0),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with chunk: GMarkChunk) {
        if let textRender = chunk.textRender {
            label.textRenderer = textRender
            return
        }
        label.attributedText = chunk.attributedText
    }

    // MARK: - MPILabelDelegate

    func label(_: MPILabel, didInteractWith link: MPITextLink, forAttributedText attributedText: NSAttributedString, in characterRange: NSRange, interaction _: MPITextItemInteraction) {
        let attributed = attributedText.attributedSubstring(from: characterRange)

        if attributed.attribute(.attachment, at: 0, effectiveRange: nil) is NSTextAttachment {
            if let imageURL = link.value as? URL {
                handlerChain?.handle(.imageClicked(imageURL))
            }
        } else if let linkURL = attributed.attribute(.link, at: 0, effectiveRange: nil) as? URL {
            handlerChain?.handle(.linkClicked(linkURL))
        }
    }
}

class GMarkCodeCell: UICollectionViewCell, ChunkCellConfigurable {
    public var handlerChain: GMarkHandlerChain?

    static let reuseIdentifier = "GMarkCodeCell"
    private let codeView: GMarkdownCodeView = {
        let codeView = GMarkdownCodeView()
        return codeView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(codeView)
        codeView.onCopy = { [weak self] copyText in
            guard let self = self else { return }
            self.handlerChain?.handle(.codeBlockCopied(copyText))
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        codeView.frame = contentView.bounds
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with chunk: GMarkChunk) {
        codeView.markChunk = chunk
    }
}

class GMarkTableCell: UICollectionViewCell, GMarkTableViewDataSource, ChunkCellConfigurable {
    static let reuseIdentifier = "GMarkTableCell"

    public var handlerChain: GMarkHandlerChain?

    let table = GMarkTableView()
    var markChunk: GMarkChunk?
    public private(set) lazy var style: GMarkTableStyle = {
        let style = GMarkTableStyle.appearance
        style.cornerRadius = 6
        style.colGap = 1
        style.gapColor = UIColor(hex: "#F2F2FF")
        return style
    }()

    var tableStyle: TableStyle {
        guard let tableStyle = markChunk?.style.tableStyle else {
            return DefaultTableStyle()
        }
        return tableStyle
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        table.backgroundColor = .white
        table.register(GMarkTableRichLabelCell.self, forCellReuseIdentifier: "GMarkTableRichLabelCell")
        table.dataSource = self
        table.style = style
        table.layer.cornerRadius = 6
        table.layer.masksToBounds = true
        contentView.addSubview(table)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        table.frame = contentView.bounds.inset(by: tableStyle.padding)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with chunk: GMarkChunk) {
        markChunk = chunk
        table.reloadData()
    }

    func headerEmpty() -> Bool {
        return (markChunk?.tableRender?.headerRenders.isEmpty) != nil
    }

    func headerRenders() -> [MPITextRenderer] {
        if let renders = markChunk?.tableRender?.headerRenders {
            return renders
        }
        return []
    }

    func bodyRenders() -> [[MPITextRenderer]] {
        if let renders = markChunk?.tableRender?.bodyRenders {
            return renders
        }
        return [[]]
    }

    func tableRenders() -> [[MPITextRenderer]] {
        let header = headerRenders()
        let headerArray = header.isEmpty ? [] : [header]
        let body = bodyRenders()
        let result = headerArray + body
        return result
    }

    // MARK: GMarkTableViewDataSource

    func numberOfRows(in _: GMarkTableView) -> Int {
        return tableRenders().count
    }

    func numberOfCols(in _: GMarkTableView) -> Int {
        return headerRenders().count
    }

    func numberOfLockingRows(in _: GMarkTableView) -> Int {
        return 0
    }

    func numberOfLockingCols(in _: GMarkTableView) -> Int {
        return 0
    }

    func table(_: GMarkTableView, lengthForRow row: Int) -> CGFloat {
        var height: CGFloat = tableStyle.cellHeight
        let renderArray = tableRenders()
        if let renders = renderArray[safe2: row] {
            for textRender in renders {
                let textheight = textRender.size().height
                height = max(height, textheight + tableStyle.cellPadding.top + tableStyle.cellPadding.bottom)
            }
        }
        return max(height, tableStyle.cellHeight)
    }

    func table(_: GMarkTableView, lengthForCol col: Int) -> CGFloat {
        let renderArray = tableRenders()
        var maxColWidth: CGFloat = 0
        for row in renderArray {
            if col < row.count {
                if let textRender = row[safe2: col] {
                    let textWidth = textRender.size().width
                    maxColWidth = max(maxColWidth, textWidth + tableStyle.cellPadding.left + tableStyle.cellPadding.right)
                }
            }
        }
        return max(maxColWidth, tableStyle.cellWidth)
    }

    func table(_ table: GMarkTableView, cellForIndexPath indexPath: TabIndexPath) -> GMarkTableViewCell? {
        guard let cell = table.dequeueReusableCell(withIdentifier: "GMarkTableRichLabelCell", for: indexPath) as? GMarkTableRichLabelCell else {
            return nil
        }

        let renders = tableRenders()

        if indexPath.row < renders.count && indexPath.col < renders[indexPath.row].count {
            let textRender = renders[indexPath.row][indexPath.col]
            cell.configure(textRender)
        }

        cell.contentInset = tableStyle.cellPadding

        if indexPath.row % 2 == 0 {
            cell.backgroundColor = .black.withAlphaComponent(0.06)
        } else {
            cell.backgroundColor = UIColor(hex: "#F2F4F7")
        }

        return cell
    }
}

class GMarkThematicCell: UICollectionViewCell, ChunkCellConfigurable {
    static let reuseIdentifier = "GMarkThematicCell"
    private let line = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(line)
        line.backgroundColor = .lightGray
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        line.frame = CGRect(x: 4, y: 0.5 * (contentView.bounds.height - 1), width: contentView.bounds.width - 8, height: 1)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with _: GMarkChunk) {}
}

public extension Array {
    subscript(safe2 index: Int) -> Element? {
        indices ~= index ? self[index] : nil
    }
}
