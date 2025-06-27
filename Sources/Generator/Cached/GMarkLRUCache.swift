//
//  GMarkLRUCache.swift
//  GMarkdown
//
//  Created by GIKI on 2025/6/28.
//


import Foundation
import UIKit

/// Notification that cache should be cleared
public let LRUCacheMemoryWarningNotification: NSNotification.Name =
    UIApplication.didReceiveMemoryWarningNotification


public final class GMarkLRUCache<Key: Hashable, Value> {
    private var values: [Key: Container] = [:]
    private unowned(unsafe) var head: Container?
    private unowned(unsafe) var tail: Container?
    private let lock: NSLock = .init()
    private var token: AnyObject?
    private let notificationCenter: NotificationCenter

    /// The current total cost of values in the cache
    public private(set) var totalCost: Int = 0

    /// The maximum total cost permitted
    public var totalCostLimit: Int {
        didSet { clean() }
    }

    /// The maximum number of values permitted
    public var countLimit: Int {
        didSet { clean() }
    }

    /// Initialize the cache with the specified `totalCostLimit` and
    /// `countLimit`
    public init(
        totalCostLimit: Int = .max,
        countLimit: Int = .max,
        notificationCenter: NotificationCenter = .default
    ) {
        self.totalCostLimit = totalCostLimit
        self.countLimit = countLimit
        self.notificationCenter = notificationCenter

        self.token = notificationCenter.addObserver(
            forName: LRUCacheMemoryWarningNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.removeAllValues()
        }
    }

    deinit {
        if let token = token {
            notificationCenter.removeObserver(token)
        }
    }
}

public extension GMarkLRUCache {
    /// The number of values currently stored in the cache
    var count: Int {
        values.count
    }

    /// Is the cache empty?
    var isEmpty: Bool {
        values.isEmpty
    }

    /// Returns all keys in the cache from oldest to newest
    var allKeys: [Key] {
        lock.lock()
        defer { lock.unlock() }
        var keys = [Key]()
        var next = head
        while let container = next {
            keys.append(container.key)
            next = container.next
        }
        return keys
    }

    /// Returns all values in the cache from oldest to newest
    var allValues: [Value] {
        lock.lock()
        defer { lock.unlock() }
        var values = [Value]()
        var next = head
        while let container = next {
            values.append(container.value)
            next = container.next
        }
        return values
    }

    /// Insert a value into the cache with optional `cost`
    func setValue(_ value: Value?, forKey key: Key, cost: Int = 0) {
        guard let value = value else {
            removeValue(forKey: key)
            return
        }
        lock.lock()
        if let container = values[key] {
            container.value = value
            totalCost -= container.cost
            container.cost = cost
            remove(container)
            append(container)
        } else {
            let container = Container(
                value: value,
                cost: cost,
                key: key
            )
            values[key] = container
            append(container)
        }
        totalCost += cost
        lock.unlock()
        clean()
    }

    /// Remove a value  from the cache and return it
    @discardableResult func removeValue(forKey key: Key) -> Value? {
        lock.lock()
        defer { lock.unlock() }
        guard let container = values.removeValue(forKey: key) else {
            return nil
        }
        remove(container)
        totalCost -= container.cost
        return container.value
    }

    /// Fetch a value from the cache
    func value(forKey key: Key) -> Value? {
        lock.lock()
        defer { lock.unlock() }
        if let container = values[key] {
            remove(container)
            append(container)
            return container.value
        }
        return nil
    }

    /// Remove all values from the cache
    func removeAllValues() {
        lock.lock()
        values.removeAll()
        head = nil
        tail = nil
        totalCost = 0
        lock.unlock()
    }
}

private extension GMarkLRUCache {
    final class Container {
        var value: Value
        var cost: Int
        let key: Key
        unowned(unsafe) var prev: Container?
        unowned(unsafe) var next: Container?

        init(value: Value, cost: Int, key: Key) {
            self.value = value
            self.cost = cost
            self.key = key
        }
    }

    // Remove container from list (must be called inside lock)
    func remove(_ container: Container) {
        if head === container {
            head = container.next
        }
        if tail === container {
            tail = container.prev
        }
        container.next?.prev = container.prev
        container.prev?.next = container.next
        container.next = nil
    }

    // Append container to list (must be called inside lock)
    func append(_ container: Container) {
        assert(container.next == nil)
        if head == nil {
            head = container
        }
        container.prev = tail
        tail?.next = container
        tail = container
    }

    // Remove expired values (must be called outside lock)
    func clean() {
        lock.lock()
        defer { lock.unlock() }
        while totalCost > totalCostLimit || count > countLimit,
              let container = head
        {
            remove(container)
            values.removeValue(forKey: container.key)
            totalCost -= container.cost
        }
    }
}
