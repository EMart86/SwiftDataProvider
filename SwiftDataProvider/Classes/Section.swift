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
    open var header: TypeAndObject?
    open var footer: TypeAndObject?
    open var rows: [Any]
    
    public init() {
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
    internal var context = Modification()
    
    open func add<Content: Comparable>(row: Content, animation: CellModifications.Animation = .automatic) {
        rows.append(row)
        context.insert(at: rows.count - 1, animation: animation)
        delegate?.didUpdateRows(for: self)
    }
    
    open func insert<Content: Comparable>(row: Content, at index: Int, animation: CellModifications.Animation = .automatic) {
        rows.insert(row, at: index)
        context.insert(at: index, animation: animation)
        delegate?.didUpdateRows(for: self)
    }
    
    open func delete<Content: Comparable>(row: Content, animation: CellModifications.Animation = .automatic) {
        guard let index = rows.index(where: { ($0 as? Content) == row } ) else {
            return
        }
        self.rows.remove(at: index)
        context.delete(at: index, animation: animation)
        delegate?.didUpdateRows(for: self)
    }
    
    open func reload(at index: Int, animation: CellModifications.Animation = .automatic) {
        context.reload(at: index, animation: animation)
        delegate?.didUpdateRows(for: self)
    }
    
    open func reload<Content: Comparable>(row: Content, animation: CellModifications.Animation = .automatic) {
        guard let index = rows.index(where: { ($0 as? Content) == row } ) else {
            return
        }
        reload(at: index, animation: animation)
    }
    
    open func content<Content>(where closure: @escaping ((Content) -> Bool)) -> Content? {
        return rows.first(where: { content in
            guard let content = content as? Content else {
                return false
            }
            return closure(content)
        }) as? Content
    }
    
    open func clear() {
        rows.enumerated().forEach {
            context.delete(at: $0.offset)
        }
        rows.removeAll()
        delegate?.didUpdateRows(for: self)
    }
    
    internal func indexPaths(for section: Int) -> (reload: [IndexPath: CellModifications.Animation]?, delete: [IndexPath: CellModifications.Animation]?, insert: [IndexPath: CellModifications.Animation]?)? {
        var reload = [IndexPath: CellModifications.Animation]()
        context.reload?.forEach {
            reload[IndexPath(row: $0, section: section)] = context.animation(for: $0) ?? .automatic
        }
        var delete = [IndexPath: CellModifications.Animation]()
        context.delete?.forEach {
            delete[IndexPath(row: $0, section: section)] = context.animation(for: $0) ?? .automatic
        }
        var insert = [IndexPath: CellModifications.Animation]()
        context.insert?.forEach {
            insert[IndexPath(row: $0, section: section)] = context.animation(for: $0) ?? .automatic
        }
        
        if reload.isEmpty && delete.isEmpty && insert.isEmpty {
            return nil
        }
        
        return (reload: reload, delete: delete, insert: insert)
    }
    
    internal func clearContext() {
        context.clear()
    }
    
    open func setNeedsUpdate(_ needsUpdate: Bool) {
        delegate?.section(self, needsReload: needsUpdate)
    }
}
