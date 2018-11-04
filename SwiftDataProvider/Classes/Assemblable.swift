//
//  Assemblable.swift
//  SwiftDataProvider
//
//  Created by Martin Eberl on 23.10.18.
//

import Foundation

public protocol Assemblable {
    var reuseIdentifier: String { get }
    func assemble(cell: UITableViewCell, with content: Any)
}

public protocol AssemblableHeaderFooter {
    var reuseIdentifier: String { get }
    func assemble(view: UITableViewHeaderFooterView, with content: Any)
}

struct Assemble<Content, TableViewCell: UITableViewCell>: Assemblable {
    let reuseIdentifier: String
    let cellType: TableViewCell.Type
    let assembler: ((TableViewCell, Content) -> Void)
    
    func assemble(cell: UITableViewCell, with content: Any) {
        guard let cell = cell as? TableViewCell, let content = content as? Content else {
            return
        }
        assembler(cell, content)
    }
}

struct AssembleHeaderFooter<Content, View: UITableViewHeaderFooterView>: AssemblableHeaderFooter {
    let reuseIdentifier: String
    let viewType: View.Type
    let assembler: ((View, Content) -> Void)
    
    func assemble(view: UITableViewHeaderFooterView, with content: Any) {
        guard let view = view as? View, let content = content as? Content else {
            return
        }
        assembler(view, content)
    }
}
