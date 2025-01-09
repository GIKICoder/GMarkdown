//
//  GMarkHandlerChain.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/31.
//

import Foundation
import UIKit

// MarkAction enum to represent different actions
public enum MarkAction {
    case textClicked(String)
    case codeBlockCopied(String)
    case linkClicked(URL)
    case imageClicked(URL)
    case custom(String, Any) // 添加自定义操作支持
}

// MarkHandler protocol
public protocol MarkHandler: AnyObject {
    associatedtype Handler: MarkHandler
    var next: Handler? { get set }
    func handle(_ action: MarkAction) -> Bool
}

class AnyMarkHandler: MarkHandler {
    fileprivate var _next: AnyMarkHandler?
    private let _handle: (MarkAction) -> Bool
    private let _isEqual: (Any) -> Bool

    var next: AnyMarkHandler? {
        get { return _next }
        set { _next = newValue }
    }

    init<H: MarkHandler>(_ handler: H) {
        _next = handler.next.map(AnyMarkHandler.init)
        _handle = handler.handle
        _isEqual = { other in
            guard let otherHandler = other as? H else { return false }
            return handler === otherHandler
        }
    }

    func handle(_ action: MarkAction) -> Bool {
        return _handle(action)
    }

    static func == (lhs: AnyMarkHandler, rhs: AnyMarkHandler) -> Bool {
        return lhs._isEqual(rhs._getBaseHandler())
    }

    private func _getBaseHandler() -> Any {
        return self
    }
}

// GMark with handler chain
public class GMarkHandlerChain {
    private var handlerChain: AnyMarkHandler?

    public func addHandler<H: MarkHandler>(_ handler: H) {
        let anyHandler = AnyMarkHandler(handler)
        anyHandler._next = handlerChain
        handlerChain = anyHandler
    }

    public func removeHandler<H: MarkHandler>(_ handler: H) {
        if let chain = handlerChain, chain == AnyMarkHandler(handler) {
            handlerChain = chain.next
            return
        }

        var current = handlerChain
        var previous: AnyMarkHandler?

        while let currentHandler = current {
            if currentHandler == AnyMarkHandler(handler) {
                previous?._next = currentHandler.next
                return
            }
            previous = currentHandler
            current = currentHandler.next
        }
    }

    public func handle(_ action: MarkAction) {
        var currentHandler = handlerChain
        while let handler = currentHandler {
            if handler.handle(action) {
                break
            }
            currentHandler = handler.next
        }
    }
}
