//
//  DynamicTableView.swift
//  DynamicTableView
//
//  Created by Martin Eberl on 06.10.18.
//

import UIKit

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

public protocol RecyclerView: class {
    var registeredCellsForContentType: [String: Assemblable] { get set }
    var registeredHeaderFooterForContentType: [String: AssemblableHeaderFooter] { get set }
    func updateHeights()
    func update(modifications: CellModifications)
    func dequeueReusableCell<Content>(for content: Content) -> UITableViewCell?
}

//MARK: - UITableView

public extension RecyclerView where Self: UITableView {
    public func updateHeights() {
        beginUpdates()
        endUpdates()
    }
    
    public func update(modifications: CellModifications) {
        beginUpdates()
        insertRows(at: Array(modifications.insertRows), with: .automatic)
        deleteRows(at: Array(modifications.deleteRows), with: .automatic)
        reloadRows(at: Array(modifications.reloadRows), with: .automatic)
        if let insertSections = modifications.insertSections {
            modifications.animations(for: insertSections).forEach {[weak self] in
                self?.insertSections(IndexSet($0.value), with: $0.key.rowAnimation)
            }
        }
        if let deleteSections = modifications.deleteSections {
            modifications.animations(for: deleteSections).forEach {[weak self] in
                self?.deleteSections(IndexSet($0.value), with: $0.key.rowAnimation)
            }
        }
        if let reloadSections = modifications.reloadSections {
            modifications.animations(for: reloadSections).forEach {[weak self] in
                self?.reloadSections(IndexSet($0.value), with: $0.key.rowAnimation)
            }
        }
        endUpdates()
    }
    
    public func register<Content, TableViewCell: UITableViewCell>(cell: TableViewCell.Type, for content: Content.Type, assemble: @escaping ((UITableViewCell, Content) -> Void)) {
        let className = String.string(from: content)
        register(cell, forCellReuseIdentifier: className)
        registeredCellsForContentType[className] = Assemble(reuseIdentifier: className, cellType: cell, assembler: assemble)
    }
    
    public func register<Content, TableViewCell: UITableViewCell>(cellReuseIdentifier: String, as cell: TableViewCell.Type, for content: Content.Type, assemble: @escaping ((UITableViewCell, Content) -> Void)) {
        let className = String.string(from: content)
        registeredCellsForContentType[className] = Assemble(reuseIdentifier: cellReuseIdentifier, cellType: cell, assembler: assemble)
    }
    
    public func dequeueReusableCell<Content>(for content: Content) -> UITableViewCell? {
        let className = String.string(from: type(of: content))
        let assembler = registeredCellsForContentType[className]
        let cell = dequeueReusableCell(withIdentifier: assembler?.reuseIdentifier ?? className)
        if let strongCell = cell {
            assembler?.assemble(cell: strongCell, with: content)
        }
        return cell
    }
    
    public func registerHeaderFooter<Content, TableHeaderView: UITableViewHeaderFooterView>(view: TableHeaderView.Type, for content: Content.Type, assemble: @escaping ((TableHeaderView, Content) -> Void)) {
        let className = String.string(from: content)
        register(view, forHeaderFooterViewReuseIdentifier: className)
        registeredHeaderFooterForContentType[className] = AssembleHeaderFooter(reuseIdentifier: className, viewType: view, assembler: assemble)
    }
    
    public func dequeueReusableHeaderFooterView<Content>(for content: Content) -> UITableViewHeaderFooterView? {
        let className = String.string(from: type(of: content))
        let assembler = registeredHeaderFooterForContentType[className]
        let cell = dequeueReusableHeaderFooterView(withIdentifier: assembler?.reuseIdentifier ?? className)
        if let strongCell = cell {
            assembler?.assemble(view: strongCell, with: content)
        }
        return cell
    }
}

//MARK: - UITableViewController

public extension RecyclerView where Self: UITableViewController {
    public func updateHeights() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    public func update(modifications: CellModifications) {
        tableView.beginUpdates()
        tableView.insertRows(at: Array(modifications.insertRows), with: .automatic)
        tableView.deleteRows(at: Array(modifications.deleteRows), with: .automatic)
        tableView.reloadRows(at: Array(modifications.reloadRows), with: .automatic)
        if let insertSections = modifications.insertSections {
            modifications.animations(for: insertSections).forEach {[weak self] in
                self?.tableView.insertSections(IndexSet($0.value), with: $0.key.rowAnimation)
            }
        }
        if let deleteSections = modifications.deleteSections {
            modifications.animations(for: deleteSections).forEach {[weak self] in
                self?.tableView.deleteSections(IndexSet($0.value), with: $0.key.rowAnimation)
            }
        }
        if let reloadSections = modifications.reloadSections {
            modifications.animations(for: reloadSections).forEach {[weak self] in
                self?.tableView.reloadSections(IndexSet($0.value), with: $0.key.rowAnimation)
            }
        }
        tableView.endUpdates()
    }
    
    public func register<Content, TableViewCell: UITableViewCell>(cell: TableViewCell.Type, for content: Content.Type, assemble: @escaping ((TableViewCell, Content) -> Void)) where TableViewCell : UITableViewCell {
        let className = String.string(from: content)
        tableView.register(cell, forCellReuseIdentifier: className)
        registeredCellsForContentType[className] = Assemble(reuseIdentifier: className, cellType: cell, assembler: assemble)
    }
    
    public func register<Content, TableViewCell: UITableViewCell>(cellReuseIdentifier: String, as cell: TableViewCell.Type, for content: Content.Type, assemble: @escaping ((TableViewCell, Content) -> Void)) {
        let className = String.string(from: content)
        registeredCellsForContentType[className] = Assemble(reuseIdentifier: cellReuseIdentifier, cellType: cell, assembler: assemble)
    }
    
    public func dequeueReusableCell<Content>(for content: Content) -> UITableViewCell? {
        let className = String.string(from: content)
        let assembler = registeredCellsForContentType[className]
        let cell = tableView.dequeueReusableCell(withIdentifier: assembler?.reuseIdentifier ?? className)
        if let strongCell = cell {
            assembler?.assemble(cell: strongCell, with: content)
        }
        return cell
    }
    
    public func registerHeaderFooter<Content, TableHeaderView: UITableViewHeaderFooterView>(view: TableHeaderView.Type, for content: Content.Type, assemble: @escaping ((TableHeaderView, Content) -> Void)) {
        let className = String.string(from: content)
        tableView.register(view, forHeaderFooterViewReuseIdentifier: className)
        registeredHeaderFooterForContentType[className] = AssembleHeaderFooter(reuseIdentifier: className, viewType: view, assembler: assemble)
    }
    
    public func dequeueReusableHeaderFooterView<Content>(for content: Content) -> UITableViewHeaderFooterView? {
        let className = String.string(from: type(of: content))
        let assembler = registeredHeaderFooterForContentType[className]
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: assembler?.reuseIdentifier ?? className)
        if let strongCell = cell {
            assembler?.assemble(view: strongCell, with: content)
        }
        return cell
    }
}

extension CellModifications.Animation {
    var rowAnimation: UITableViewRowAnimation {
        switch self {
        case .fade:
            return .fade
        case .right:
            return .right
        case .left:
            return .left
        case .bottom:
            return .bottom
        case .none:
            return .none
        case .middle:
            return .middle
        case .automatic:
            return .automatic
        }
    }
}
