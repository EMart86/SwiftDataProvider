//
//  DynamicTableView.swift
//  DynamicTableView
//
//  Created by Martin Eberl on 06.10.18.
//

import UIKit

public protocol RecyclerView: class {
    var dataSource: UITableViewDataSource? { get set }
    var delegate: UITableViewDelegate? { get set }
    func updateHeights()
    func update(modifications: CellModifications)
    func reloadData()
    
    // MARK: - if Recycler View is in UITableView
    func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String)
    func register(_ nib: UINib?, forCellReuseIdentifier identifier: String)
    func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell?
    func register(_ aClass: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String)
    func register(_ nib: UINib?, forHeaderFooterViewReuseIdentifier identifier: String)
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
        let insert = modifications.animations(for: Array(modifications.insertRows))
        for i in insert {
            insertRows(at: i.value, with: i.key.rowAnimation)
        }
        let delete = modifications.animations(for: Array(modifications.deleteRows))
        for i in delete {
            deleteRows(at: i.value, with: i.key.rowAnimation)
        }
        let reload = modifications.animations(for: Array(modifications.reloadRows))
        for i in reload {
            reloadRows(at: i.value, with: i.key.rowAnimation)
        }
        
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
    
    public var delegate: UITableViewDelegate? {
        set {
            tableView.delegate = newValue
        }
        get {
            return tableView.delegate
        }
    }
    
    public func updateHeights() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    public func update(modifications: CellModifications) {
        tableView.beginUpdates()
        let insert = modifications.animations(for: Array(modifications.insertRows))
        for i in insert {
            tableView.insertRows(at: i.value, with: i.key.rowAnimation)
        }
        let delete = modifications.animations(for: Array(modifications.deleteRows))
        for i in delete {
            tableView.deleteRows(at: i.value, with: i.key.rowAnimation)
        }
        let reload = modifications.animations(for: Array(modifications.reloadRows))
        for i in reload {
            tableView.reloadRows(at: i.value, with: i.key.rowAnimation)
        }
        
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
    
    func register(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
        tableView.register(nib, forCellReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: identifier)
    }
    
    func register(_ aClass: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String) {
        tableView.register(aClass, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    func register(_ nib: UINib?, forHeaderFooterViewReuseIdentifier identifier: String) {
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    func dequeueReusableHeaderFooterView(withIdentifier identifier: String) -> UITableViewHeaderFooterView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
    }
    
    func reloadData() {
        tableView.reloadData()
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
    var rowAnimation: UITableView.RowAnimation {
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
