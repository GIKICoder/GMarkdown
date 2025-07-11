import Foundation
import SwiftSyntax

public protocol SwiftSyntaxHighlightRule: Sendable {
    func attributes(for token: TokenSyntax) -> NSAttributedString?
}

enum WalkParentAction<T> {
    case found(T)
    case notFound
    case moveToParent
}

extension SwiftSyntaxHighlightRule {
    func walkParent<T>(of node: Syntax, handler: (Syntax) -> WalkParentAction<T>) -> T? {
        var currentNode: Syntax? = node
        while let node = currentNode {
            let result = handler(node)
            switch result {
            case .found(let value): return value
            case .notFound: return nil
            case .moveToParent: currentNode = node.parent
            }
        }
        return nil
    }
}
