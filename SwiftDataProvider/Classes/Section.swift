//
//  Section.swift
//  SwiftDataProvider
//
//  Created by Martin Eberl on 23.10.18.
//

import Foundation

protocol SectionDelegate: class {
    func section(_ section: Section, needsReload: Bool)
    func didUpdateRows(for section: Section)
}

public struct TypeAndObject {
    public var object: Any
    public var type: String
}

open class Section {
    public struct Keys {
        public static let predicate = "Section.Key.Predicate"
    }
    
    internal var header: TypeAndObject?
    internal var footer: TypeAndObject?
    open var rows: [Any]
    open var insertPredicate: NSPredicate?
    public let context: [String: Any]?
    
    public init(context: [String: Any]? = nil) {
        self.context = context
        self.header = nil
        self.footer = nil
        self.rows = []
    }
    
    public func set<Header>(header: Header) {
        self.header = TypeAndObject(object: header, type: String(describing: type(of: header)))
    }
    
    public func set<Footer>(footer: Footer) {
        self.footer = TypeAndObject(object: footer, type: String(describing: type(of: footer)))
    }
    
    internal weak var delegate: SectionDelegate?
    internal var modification = Modification()
    
    internal var totalRows: [Any] {
        var total = rows
        if let delete = modification.delete {
            for index in delete.reversed() {
                total.remove(at: index)
            }
        }
        total = total + (modification.insert?.values.map { $0 } ?? [Any]())
        return total
    }
    
    open func add<Content>(row: Content, animation: CellModifications.Animation = .automatic) {
        guard insertPredicate == nil || meetsPredicate(content: row).isTrue else {
            return
        }
        //        rows.append(row)
        modification.insert(content: row, at: totalRows.count, animation: animation)
    }
    
    open func  insert<Content>(row: Content, at index: Int, animation: CellModifications.Animation = .automatic) {
        guard insertPredicate == nil || meetsPredicate(content: row).isFalse else {
            return
        }
        //        rows.insert(row, at: index)
        modification.insert(content: row, at: index, animation: animation)
    }
    
    open func delete<Content: Comparable>(row: Content, animation: CellModifications.Animation = .automatic) {
        guard let index = rows.index(where: { ($0 as? Content) == row } ) else {
            return
        }
        delete(at: index, animation: animation)
    }
    
    open func delete(at index: Int, animation: CellModifications.Animation = .automatic) {
        //        rows.remove(at: index)
        modification.delete(at: index, animation: animation)
    }
    
    open func replace(row: Any, at index: Int, animation: CellModifications.Animation = .automatic) {
        modification.reload(content: context, at: index, animation: animation)
    }
    
    open func reload(at index: Int, animation: CellModifications.Animation = .automatic) {
        modification.reload(at: index, animation: animation)
    }
    
    open func reload<Content: Comparable>(row: Content, animation: CellModifications.Animation = .automatic) {
        guard let index = rows.index(where: { ($0 as? Content) == row } ) else {
            return
        }
        reload(at: index, animation: animation)
    }
    
    open func content<Content>(where closure: ((Content) -> Bool)) -> Content? {
        return rows.first(where: { content in
            guard let content = content as? Content else {
                return false
            }
            return closure(content)
        }) as? Content
    }
    
    open func clear(animation: CellModifications.Animation = .automatic) {
        rows.enumerated().forEach {
            modification.delete(at: $0.offset, animation: animation)
        }
    }
    
    open func meetsPredicate(content: Any) -> Bool? {
        return insertPredicate?.evaluate(with: content)
    }
    
    internal func indexPaths(for section: Int) -> (reload: [IndexPath: CellModifications.Animation]?, delete: [IndexPath: CellModifications.Animation]?, insert: [IndexPath: CellModifications.Animation]?)? {
        var reload = [IndexPath: CellModifications.Animation]()
        modification.reload?.forEach {
            if let value = $0.value {
                rows[$0.key] = value
            }
            reload[IndexPath(row: $0.key, section: section)] = modification.animation(for: $0.key) ?? .automatic
        }
        var delete = [IndexPath: CellModifications.Animation]()
        modification.delete?.forEach {
            rows.remove(at: $0)
            delete[IndexPath(row: $0, section: section)] = modification.animation(for: $0) ?? .automatic
        }
        var insert = [IndexPath: CellModifications.Animation]()
        modification.insert?.keys.sorted().forEach { key in
            guard let value = modification.insert?[key] else {
                return
            }
            
            rows.insert(value, at: key)
            insert[IndexPath(row: key, section: section)] = modification.animation(for: key) ?? .automatic
        }
        
        if reload.isEmpty && delete.isEmpty && insert.isEmpty {
            return nil
        }
        
        delegate?.didUpdateRows(for: self)
        
        return (reload: reload, delete: delete, insert: insert)
    }
    
    internal func clearModification() {
        modification.clear()
    }
    
    open func setNeedsUpdate(_ needsUpdate: Bool) {
        delegate?.section(self, needsReload: needsUpdate)
    }
}
