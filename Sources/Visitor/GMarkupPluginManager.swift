//
//  GMarkupPluginManager.swift
//  GMarkdown
//
//  Created by GIKI on 2025/7/5.
//

import Foundation
import Markdown
import UIKit
#if canImport(MPITextKit)
import MPITextKit
#endif

/// 支持优先级的插件协议
public protocol HasPriority {
    var priority: Int { get }
}

/// 插件管理器，负责管理和调度所有插件
public class GMarkupPluginManager {
    public static let shared = GMarkupPluginManager()
    
    private var plugins: [GMarkupPlugin] = []
    private var pluginCache: [String: GMarkupPlugin] = [:]
    
    private init() {
        // 注册默认插件
        registerDefaultPlugins()
    }
    
    // MARK: - Plugin Management
    
    /// 注册默认插件
    private func registerDefaultPlugins() {
        register(DefaultCodePlugin())
        register(DefaultTablePlugin())
        register(DefaultImagePlugin())
        register(DefaultHTMLBlockPlugin())
        register(DefaultInlineHTMLPlugin())
    }
    
    /// 注册插件
    public func register(_ plugin: GMarkupPlugin) {
        // 检查是否已存在相同标识符的插件
        if let existingIndex = plugins.firstIndex(where: { $0.identifier == plugin.identifier }) {
            // 替换现有插件
            plugins[existingIndex] = plugin
        } else {
            // 添加新插件
            plugins.append(plugin)
        }
        
        // 按优先级排序（如果插件支持优先级）
        plugins.sort { plugin1, plugin2 in
            // 检查插件是否有优先级属性
            let priority1 = (plugin1 as? any GMarkupPlugin & HasPriority)?.priority ?? 0
            let priority2 = (plugin2 as? any GMarkupPlugin & HasPriority)?.priority ?? 0
            return priority1 > priority2
        }
        
        // 更新缓存
        pluginCache[plugin.identifier] = plugin
    }
    
    /// 取消注册插件
    public func unregister(identifier: String) {
        plugins.removeAll { $0.identifier == identifier }
        pluginCache.removeValue(forKey: identifier)
    }
    
    /// 获取指定标识符的插件
    public func getPlugin(identifier: String) -> GMarkupPlugin? {
        return pluginCache[identifier]
    }
    
    /// 获取所有插件
    public func getAllPlugins() -> [GMarkupPlugin] {
        return plugins
    }
    
    // MARK: - Unified Handling Methods
    
    /// 统一的处理方法 - 通过插件系统处理 Markup
    /// - Parameters:
    ///   - markup: 需要处理的 Markup 元素
    ///   - visitor: GMarkupAttachVisitor 实例
    /// - Returns: 处理后的 NSAttributedString，如果没有插件能处理则返回 nil
    public func handle(_ markup: Markup, visitor: inout GMarkupAttachVisitor) -> NSAttributedString? {
        // 按优先级顺序处理，第一个能处理的插件返回结果
        for plugin in plugins {
            if plugin.canHandle(markup) {
                if let result = plugin.handle(markup, visitor: &visitor) {
                    return result
                }
            }
        }
        return nil
    }
    
    /// 统一的处理方法 - 通过插件系统处理 Markup（可选择特定插件类型）
    /// - Parameters:
    ///   - markup: 需要处理的 Markup 元素
    ///   - visitor: GMarkupAttachVisitor 实例
    ///   - pluginType: 指定插件类型
    /// - Returns: 处理后的 NSAttributedString，如果没有指定类型的插件能处理则返回 nil
    public func handle<T: GMarkupPlugin>(_ markup: Markup, visitor: inout GMarkupAttachVisitor, pluginType: T.Type) -> NSAttributedString? {
        let specificPlugins = plugins.compactMap { $0 as? T }
        
        for plugin in specificPlugins {
            if plugin.canHandle(markup) {
                if let result = plugin.handle(markup, visitor: &visitor) {
                    return result
                }
            }
        }
        return nil
    }
    
    /// 批量处理多个Markup元素
    /// - Parameters:
    ///   - markups: 要处理的Markup元素数组
    ///   - visitor: 访问者对象
    /// - Returns: 处理后的NSAttributedString数组
    public func handleMultiple(_ markups: [Markup], visitor: inout GMarkupAttachVisitor) -> [NSAttributedString] {
        return markups.compactMap { handle($0, visitor: &visitor) }
    }
    
    /// 获取能处理指定Markup的所有插件
    /// - Parameter markup: 要处理的Markup元素
    /// - Returns: 能处理该Markup的插件数组，按优先级排序
    public func getPluginsForMarkup(_ markup: Markup) -> [GMarkupPlugin] {
        return plugins.filter { $0.canHandle(markup) }
                     .sorted { plugin1, plugin2 in
                         let priority1 = (plugin1 as? any GMarkupPlugin & HasPriority)?.priority ?? 0
                         let priority2 = (plugin2 as? any GMarkupPlugin & HasPriority)?.priority ?? 0
                         return priority1 > priority2
                     }
    }
    
    /// 获取能处理指定Markup的第一个插件
    /// - Parameter markup: 要处理的Markup元素
    /// - Returns: 能处理该Markup的第一个插件（优先级最高）
    public func getFirstHandlerPlugin(for markup: Markup) -> GMarkupPlugin? {
        return plugins.filter { $0.canHandle(markup) }
                     .sorted { plugin1, plugin2 in
                         let priority1 = (plugin1 as? any GMarkupPlugin & HasPriority)?.priority ?? 0
                         let priority2 = (plugin2 as? any GMarkupPlugin & HasPriority)?.priority ?? 0
                         return priority1 > priority2
                     }
                     .first
    }
    
    /// 检查是否有插件能处理指定的Markup
    /// - Parameter markup: 要检查的Markup元素
    /// - Returns: 如果有插件能处理则返回true，否则返回false
    public func canHandle(_ markup: Markup) -> Bool {
        return plugins.contains { $0.canHandle(markup) }
    }
    
    /// 获取插件处理统计信息
    /// - Returns: 包含插件类型统计的字典
    public func getPluginStatistics() -> [String: Int] {
        var statistics: [String: Int] = [:]
        
        for plugin in plugins {
            let type = String(describing: type(of: plugin))
            statistics[type] = (statistics[type] ?? 0) + 1
        }
        
        return statistics
    }
    
    /// 清空所有插件
    public func clearAll() {
        plugins.removeAll()
        pluginCache.removeAll()
    }
    
    /// 重置为默认插件
    public func resetToDefault() {
        clearAll()
        registerDefaultPlugins()
    }
}

/// 插件管理器扩展 - 提供便捷的插件注册方法
extension GMarkupPluginManager {
    /// 注册代码块插件
    public func registerCodePlugin(_ plugin: GMarkupCodePlugin) {
        register(plugin)
    }
    
    /// 注册表格插件
    public func registerTablePlugin(_ plugin: GMarkupTablePlugin) {
        register(plugin)
    }
    
    /// 注册图片插件
    public func registerImagePlugin(_ plugin: GMarkupImagePlugin) {
        register(plugin)
    }
    
    /// 注册HTML块插件
    public func registerHTMLBlockPlugin(_ plugin: GMarkupHTMLBlockPlugin) {
        register(plugin)
    }
    
    /// 注册内联HTML插件
    public func registerInlineHTMLPlugin(_ plugin: GMarkupInlineHTMLPlugin) {
        register(plugin)
    }
}
