//
//  GMarkupTableVisitor.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/26.
//

import Foundation
import Markdown
#if canImport(MPITextKit)
    import MPITextKit
#endif

public struct GMarkTable {
    var columnAlignments: [Table.ColumnAlignment?]?
    var maxColumnCount: Int?
    var headers: [NSAttributedString]? = []
    var bodys: [[NSAttributedString]]? = []
    var contents: String = ""
}

public struct GMarkupTableVisitor: MarkupVisitor {
    private let style: Style
    private var markTable: GMarkTable

    init(style: Style) {
        self.style = style
        markTable = GMarkTable()
    }

    public typealias Result = GMarkTable

    public mutating func defaultVisit(_ markup: Markup) -> GMarkTable {
        for child in markup.children {
            _ = visit(child)
        }
        return markTable
    }

    /**
     Visit a `Table` element and return the result.

     - parameter table: A `Table` element.
     - returns: The result of the visit.
     */
    public mutating func visitTable(_ table: Table) -> GMarkTable {
        markTable.columnAlignments = table.columnAlignments
        markTable.maxColumnCount = table.maxColumnCount
        _ = visit(table.head)
        _ = visit(table.body)
        return markTable
    }

    /**
     Visit a `Table.Head` element and return the result.

     - parameter tableHead: A `Table.Head` element.
     - returns: The result of the visit.
     */
    public mutating func visitTableHead(_ tableHead: Table.Head) -> GMarkTable {
        var headers: [NSAttributedString] = []
        for child in tableHead.cells {
            var visitor = GMarkupVisitor(style: style)
            let attribute = visitor.visit(child)
            markTable.contents += attribute.string
            headers.append(attribute)
        }
        markTable.headers = headers
        return markTable
    }

    /**
     Visit a `Table.Body` element and return the result.

     - parameter tableBody: A `Table.Body` element.
     - returns: The result of the visit.
     */
    public mutating func visitTableBody(_ tableBody: Table.Body) -> GMarkTable {
        for child in tableBody.rows {
            _ = visitTableRow(child)
        }
        return markTable
    }

    /**
     Visit a `Table.Row` element and return the result.

     - parameter tableRow: A `Table.Row` element.
     - returns: The result of the visit.
     */
    public mutating func visitTableRow(_ tableRow: Table.Row) -> GMarkTable {
        var rows: [NSAttributedString] = []
        for child in tableRow.cells {
            var visitor = GMarkupVisitor(style: style)
            let attribute = visitor.visit(child)
            markTable.contents += attribute.string
            rows.append(attribute)
        }
        if rows.count > 0 {
            markTable.bodys?.append(rows)
        }
        return markTable
    }
}
