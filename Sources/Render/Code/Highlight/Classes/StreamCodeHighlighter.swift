//
//  StreamCodeHighlighter.swift
//  GMarkdown
//
//  Created by GIKI on 2025/6/28.
//

import Foundation

#if os(OSX)
    import AppKit
#elseif os(iOS)
    import UIKit
#endif

/// NSTextStorage subclass. Can be used to dynamically highlight code with incremental processing.
open class StreamCodeHighlighter: NSTextStorage {
    /// Internal Storage
    let stringStorage = NSTextStorage()
    
    /// Highlightr instace used internally for highlighting
    public let highlightr: Highlightr
    
    /// This object will be notified before and after the highlighting
    open var highlightDelegate: HighlightDelegate?
    
    // MARK: - Incremental Processing Properties
    
    /// 缓存已处理的内容，避免重复高亮
    private var processedRanges: [NSRange] = []
    
    /// 增量处理的批次大小
    public var batchSize: Int = 1000
    
    /// 处理延迟，避免频繁更新
    public var processingDelay: TimeInterval = 0.1
    
    /// 当前处理任务的标识符
    private var currentProcessingId = UUID()
    
    /// 待处理的队列
    private var pendingRanges: [NSRange] = []
    
    /// 是否正在处理
    private var isProcessing = false
    
    /// 处理队列
    private let processingQueue = DispatchQueue(label: "code.highlighting", qos: .userInitiated)
    
    /// 定时器用于批量处理
    private var processingTimer: Timer?
    
    // MARK: - Initialization
    
    public init(highlightr: Highlightr = Highlightr()!) {
        self.highlightr = highlightr
        super.init()
        setupListeners()
    }
    
    override public init() {
        highlightr = Highlightr()!
        super.init()
        setupListeners()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        highlightr = Highlightr()!
        super.init(coder: aDecoder)
        setupListeners()
    }
    
    #if os(OSX)
    public required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        highlightr = Highlightr()!
        super.init(pasteboardPropertyList: propertyList, ofType: type)
        setupListeners()
    }
    #endif
    
    // MARK: - Public Methods
    
    @objc public func generateAttributeText(_ string: String, language: String) -> NSAttributedString? {
        return highlightr.highlight(string, as: language)
    }
    
    @objc public func generateAttributeText(_ string: String) -> NSAttributedString? {
        return highlightr.highlight(string, as: nil)
    }
    
    /// 强制重新高亮所有内容
    public func forceRefreshHighlighting() {
        processedRanges.removeAll()
        currentProcessingId = UUID()
        highlight(NSMakeRange(0, stringStorage.length))
    }
    
    /// 清除处理缓存
    public func clearProcessingCache() {
        processedRanges.removeAll()
        pendingRanges.removeAll()
        processingTimer?.invalidate()
        processingTimer = nil
        isProcessing = false
    }
    
    // MARK: - Properties
    
    open var language: String? {
        didSet {
            if language != oldValue {
                forceRefreshHighlighting()
            }
        }
    }
    
    override open var string: String {
        return stringStorage.string
    }
    
    // MARK: - NSTextStorage Overrides
    
    override open func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [AttributedStringKey: Any] {
        return stringStorage.attributes(at: location, effectiveRange: range)
    }
    
    override open func replaceCharacters(in range: NSRange, with str: String) {
        // 更新已处理范围缓存
        updateProcessedRangesForEdit(in: range, changeInLength: (str as NSString).length - range.length)
        
        stringStorage.replaceCharacters(in: range, with: str)
        edited(TextStorageEditActions.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)
    }
    
    override open func setAttributes(_ attrs: [AttributedStringKey: Any]?, range: NSRange) {
        stringStorage.setAttributes(attrs, range: range)
        edited(TextStorageEditActions.editedAttributes, range: range, changeInLength: 0)
    }
    
    override open func processEditing() {
        super.processEditing()
        
        if language != nil && editedMask.contains(.editedCharacters) {
            let string = (self.string as NSString)
            let range = string.paragraphRange(for: editedRange)
            
            // 使用增量处理
            scheduleIncrementalHighlighting(for: range)
        }
    }
    
    // MARK: - Incremental Processing
    
    /// 调度增量高亮处理
    private func scheduleIncrementalHighlighting(for range: NSRange) {
        // 检查是否已经处理过这个范围
        if isRangeProcessed(range) {
            return
        }
        
        // 添加到待处理队列
        pendingRanges.append(range)
        
        // 取消之前的定时器
        processingTimer?.invalidate()
        
        // 设置新的定时器进行批量处理
        processingTimer = Timer.scheduledTimer(withTimeInterval: processingDelay, repeats: false) { [weak self] _ in
            self?.processPendingRanges()
        }
    }
    
    /// 处理待处理的范围
    private func processPendingRanges() {
        guard !isProcessing && !pendingRanges.isEmpty else { return }
        
        isProcessing = true
        let rangesToProcess = mergePendingRanges()
        pendingRanges.removeAll()
        
        // 分批处理
        processRangesInBatches(rangesToProcess)
    }
    
    /// 合并重叠的待处理范围
    private func mergePendingRanges() -> [NSRange] {
        guard !pendingRanges.isEmpty else { return [] }
        
        let sortedRanges = pendingRanges.sorted { $0.location < $1.location }
        var mergedRanges: [NSRange] = []
        var currentRange = sortedRanges[0]
        
        for range in sortedRanges.dropFirst() {
            if NSMaxRange(currentRange) >= range.location {
                // 合并重叠范围
                currentRange = NSUnionRange(currentRange, range)
            } else {
                mergedRanges.append(currentRange)
                currentRange = range
            }
        }
        mergedRanges.append(currentRange)
        
        return mergedRanges
    }
    
    /// 分批处理范围
    private func processRangesInBatches(_ ranges: [NSRange]) {
        let processingId = UUID()
        currentProcessingId = processingId
        
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            
            for range in ranges {
                // 检查处理是否被取消
                if self.currentProcessingId != processingId {
                    break
                }
                
                // 将大范围分割成小批次
                let batches = self.splitRangeIntoBatches(range)
                
                for batch in batches {
                    if self.currentProcessingId != processingId {
                        break
                    }
                    
                    self.highlightBatch(batch, processingId: processingId)
                    
                    // 添加小延迟，避免阻塞主线程
                    Thread.sleep(forTimeInterval: 0.001)
                }
            }
            
            DispatchQueue.main.async {
                self.isProcessing = false
            }
        }
    }
    
    /// 将范围分割成批次
    private func splitRangeIntoBatches(_ range: NSRange) -> [NSRange] {
        var batches: [NSRange] = []
        var currentLocation = range.location
        let endLocation = NSMaxRange(range)
        
        while currentLocation < endLocation {
            let batchLength = min(batchSize, endLocation - currentLocation)
            let batchRange = NSMakeRange(currentLocation, batchLength)
            batches.append(batchRange)
            currentLocation += batchLength
        }
        
        return batches
    }
    
    /// 高亮单个批次
    private func highlightBatch(_ range: NSRange, processingId: UUID) {
        guard language != nil else { return }
        
        // 检查是否应该高亮
        if let highlightDelegate = highlightDelegate {
            let shouldHighlight: Bool? = highlightDelegate.shouldHighlight?(range)
            if shouldHighlight != nil && !shouldHighlight! {
                return
            }
        }
        
        let string = (self.string as NSString)
        
        // 确保范围有效
        guard range.location + range.length <= string.length else {
            DispatchQueue.main.async {
                self.highlightDelegate?.didHighlight?(range, success: false)
            }
            return
        }
        
        let line = string.substring(with: range)
        let tmpStrg = self.highlightr.highlight(line, as: self.language!)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  self.currentProcessingId == processingId else { return }
            
            // 验证内容是否仍然匹配
            if (range.location + range.length) > self.stringStorage.length {
                self.highlightDelegate?.didHighlight?(range, success: false)
                return
            }
            
            if tmpStrg?.string != self.stringStorage.attributedSubstring(from: range).string {
                self.highlightDelegate?.didHighlight?(range, success: false)
                return
            }
            
            // 应用高亮
            self.applyHighlighting(tmpStrg, to: range)
            
            // 标记为已处理
            self.markRangeAsProcessed(range)
            
            self.highlightDelegate?.didHighlight?(range, success: true)
        }
    }
    
    /// 应用高亮到指定范围
    private func applyHighlighting(_ attributedString: NSAttributedString?, to range: NSRange) {
        guard let tmpStrg = attributedString else { return }
        
        self.beginEditing()
        
        tmpStrg.enumerateAttributes(in: NSMakeRange(0, tmpStrg.length), options: []) { attrs, locRange, _ in
            var fixedRange = NSMakeRange(range.location + locRange.location, locRange.length)
            let stringLength = self.stringStorage.length
            
            // 确保范围有效
            fixedRange.length = (fixedRange.location + fixedRange.length < stringLength) ? fixedRange.length : stringLength - fixedRange.location
            fixedRange.length = max(0, fixedRange.length)
            
            if fixedRange.length > 0 {
                self.stringStorage.setAttributes(attrs, range: fixedRange)
            }
        }
        
        self.endEditing()
        self.edited(TextStorageEditActions.editedAttributes, range: range, changeInLength: 0)
    }
    
    // MARK: - Range Management
    
    /// 检查范围是否已处理
    private func isRangeProcessed(_ range: NSRange) -> Bool {
        return processedRanges.contains { NSIntersectionRange($0, range).length > 0 }
    }
    
    /// 标记范围为已处理
    private func markRangeAsProcessed(_ range: NSRange) {
        processedRanges.append(range)
        
        // 定期清理和合并已处理的范围，避免内存泄漏
        if processedRanges.count > 100 {
            mergeProcessedRanges()
        }
    }
    
    /// 合并已处理的范围
    private func mergeProcessedRanges() {
        let sortedRanges = processedRanges.sorted { $0.location < $1.location }
        var mergedRanges: [NSRange] = []
        
        guard !sortedRanges.isEmpty else {
            processedRanges = []
            return
        }
        
        var currentRange = sortedRanges[0]
        
        for range in sortedRanges.dropFirst() {
            if NSMaxRange(currentRange) >= range.location {
                currentRange = NSUnionRange(currentRange, range)
            } else {
                mergedRanges.append(currentRange)
                currentRange = range
            }
        }
        mergedRanges.append(currentRange)
        
        processedRanges = mergedRanges
    }
    
    /// 更新编辑后的已处理范围
    private func updateProcessedRangesForEdit(in range: NSRange, changeInLength delta: Int) {
        processedRanges = processedRanges.compactMap { processedRange in
            if NSMaxRange(processedRange) <= range.location {
                // 在编辑位置之前，不受影响
                return processedRange
            } else if processedRange.location >= NSMaxRange(range) {
                // 在编辑位置之后，需要调整位置
                return NSMakeRange(processedRange.location + delta, processedRange.length)
            } else {
                // 与编辑范围重叠，标记为需要重新处理
                return nil
            }
        }
    }
    
    // MARK: - Original Methods (Modified)
    
    func highlight(_ range: NSRange) {
        scheduleIncrementalHighlighting(for: range)
    }
    
    func setupListeners() {
        highlightr.themeChanged = { [weak self] _ in
            guard let self = self else { return }
            self.forceRefreshHighlighting()
        }
    }
    
    deinit {
        processingTimer?.invalidate()
        clearProcessingCache()
    }
}
