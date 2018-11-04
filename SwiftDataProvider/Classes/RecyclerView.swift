//
//  DynamicTableView.swift
//  DynamicTableView
//
//  Created by Martin Eberl on 06.10.18.
//

import UIKit

public protocol RecyclerView: class {
    var dataSource: UITableViewDataSource? { get set }
    func updateHeights()
    func update(modifications: CellModifications)
    
    // MARK: - if Recycler View is in UITableView
    func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String)
    func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell?
    func register(_ aClass: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String)
    func dequeueReusableHeaderFooterView(withIdentifier identifier: String) -> UITableViewHeaderFooterView?
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
}

//MARK: - UITableViewController

public extension RecyclerView where Self: UITableViewController {
    
    public var dataSource: UITableViewDataSource? {
        set {
            tableView.dataSource = newValue
        }
        get {
            return tableView.dataSource
        }
    }
    
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
    
    func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        tableView.register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: identifier)
    }
    
    func register(_ aClass: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String) {
        tableView.register(aClass, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    func dequeueReusableHeaderFooterView(withIdentifier identifier: String) -> UITableViewHeaderFooterView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
    }
}

// MARK - DEPRECATIONS
public extension RecyclerView where Self: UITableView {
    @available(*, deprecated, message: "Moved to SwiftDataProvider")
    public func register<Content, TableViewCell: UITableViewCell>(cell: TableViewCell.Type, for content: Content.Type, assemble: @escaping ((UITableViewCell, Content) -> Void)) {
    }
    
    @available(*, deprecated, message: "Moved to SwiftDataProvider")
    public func register<Content, TableViewCell: UITableViewCell>(cellReuseIdentifier: String, as cell: TableViewCell.Type, for content: Content.Type, assemble: @escaping ((TableViewCell, Content) -> Void)) {
    }
    
    @available(*, deprecated, message: "Moved to SwiftDataProvider")
    public func dequeueReusableCell<Content>(for content: Content) -> UITableViewCell? {
        return nil
    }
    
    @available(*, deprecated, message: "Moved to SwiftDataProvider")
    public func registerHeaderFooter<Content, TableHeaderView: UITableViewHeaderFooterView>(view: TableHeaderView.Type, for content: Content.Type, assemble: @escaping ((TableHeaderView, Content) -> Void)) {
    }
    
    @available(*, deprecated, message: "Moved to SwiftDataProvider")
    public func dequeueReusableHeaderFooterView<Content>(for content: Content) -> UITableViewHeaderFooterView? {
        return nil
    }
}

public extension RecyclerView where Self: UITableViewController {
    @available(*, deprecated, message: "Moved to SwiftDataProvider")
    public func register<Content, TableViewCell: UITableViewCell>(cell: TableViewCell.Type, for content: Content.Type, assemble: @escaping ((UITableViewCell, Content) -> Void)) {
    }
    
    @available(*, deprecated, message: "Moved to SwiftDataProvider")
    public func register<Content, TableViewCell: UITableViewCell>(cellReuseIdentifier: String, as cell: TableViewCell.Type, for content: Content.Type, assemble: @escaping ((TableViewCell, Content) -> Void)) {
    }
    
    @available(*, deprecated, message: "Moved to SwiftDataProvider")
    public func dequeueReusableCell<Content>(for content: Content) -> UITableViewCell? {
        return nil
    }
    
    @available(*, deprecated, message: "Moved to SwiftDataProvider")
    public func registerHeaderFooter<Content, TableHeaderView: UITableViewHeaderFooterView>(view: TableHeaderView.Type, for content: Content.Type, assemble: @escaping ((TableHeaderView, Content) -> Void)) {
    }
    
    @available(*, deprecated, message: "Moved to SwiftDataProvider")
    public func dequeueReusableHeaderFooterView<Content>(for content: Content) -> UITableViewHeaderFooterView? {
        return nil
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
