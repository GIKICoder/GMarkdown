import SyntaxInk
import SwiftSyntax
import SwiftParser

public struct SwiftGrammar: Grammar {
    public typealias Token = SwiftSyntax.TokenSyntax

    public init() {}

    public func tokenize(_ code: String) -> [TokenSyntax] {
        let syntaxTree = Parser.parse(source: code)
        let tokenCollector = TokenCollector()
        tokenCollector.walk(syntaxTree)
        return tokenCollector.tokens
    }
}

private final class TokenCollector: SyntaxVisitor {
    var tokens: [TokenSyntax] = []

    init() {
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ token: TokenSyntax) -> SyntaxVisitorContinueKind {
        tokens.append(token)
        return super.visit(token)
    }
}
