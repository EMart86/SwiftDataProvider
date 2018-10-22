//
//  CellModifications.swift
//  DynamicTableView
//
//  Created by Martin Eberl on 07.10.18.
//

import Foundation

public class Modification {
    private(set) var reload: [Int]?
    private(set) var insert: [Int]?
    private(set) var delete: [Int]?
    
    public init(reload: [Int]? = nil,
                insert: [Int]? = nil,
                delete: [Int]? = nil) {
        self.reload = reload
        self.delete = delete
        self.insert = insert
    }
    
    public func insert(at index: Int) {
        if let _index = delete?.index(of: index) {
            delete?.remove(at: _index)
            reload?.append(index)
            return
        }
        var insert = self.insert ?? [Int]()
        insert.append(index)
        self.insert = insert
    }
    
    public func reload(at index: Int) {
        if insert?.contains(index) == true {
            return
        }
        if let _index = delete?.index(of: index) {
            delete?.remove(at: _index)
        }
        var reload = self.reload ?? [Int]()
        reload.append(index)
        self.reload = reload
    }
    
    public func delete(at index: Int) {
        if let _index = insert?.index(of: index) {
            insert?.remove(at: _index)
        }
        if let _index = reload?.index(of: index) {
            reload?.remove(at: _index)
        }
        var delete = self.delete ?? [Int]()
        delete.append(index)
        self.delete = delete
    }
    
    public func clear() {
        reload = nil
        insert = nil
        delete = nil
    }
}

public class CellModifications {
    public enum Animation: Int {
        case fade
        case right           // slide in from right (or out to right)
        case left
        case bottom
        case none            // available in iOS 3.0
        case middle          // available in iOS 3.2.  attempts to keep cell centered in the space it will/did occupy
        case automatic = 100 // available in iOS 5.0.  chooses an appropriate animation style for you
    }
    
    private(set) var reloadSections: IndexSet?
    private(set) var insertSections: IndexSet?
    private(set) var deleteSections: IndexSet?
    internal var reloadRows: Set<IndexPath>
    internal var insertRows: Set<IndexPath>
    internal var deleteRows: Set<IndexPath>
    
    public init(reloadRows: Set<IndexPath> =  Set(),
              insertRows: Set<IndexPath> = Set(),
              deleteRows: Set<IndexPath> = Set(),
              reloadSections: IndexSet? = nil,
              insertSections: IndexSet? = nil,
              deleteSections: IndexSet? = nil) {
        self.reloadRows = reloadRows
        self.deleteRows = deleteRows
        self.insertRows = insertRows
        self.reloadSections = reloadSections
        self.deleteSections = deleteSections
        self.insertSections = insertSections
    }
    
    private var indexAnimationMapper = [Int: Animation]()
    
    public func animations(for indexSet: IndexSet) -> [Animation: [Int]] {
        var mapper = [Animation: [Int]]()
        for i in indexSet {
            if let animation = indexAnimationMapper[i] {
                var indexes = mapper[animation] ?? [Int]()
                indexes.append(i)
                mapper[animation] = indexes
            }
        }
        return mapper
    }
    
    public func insertSection(at index: Int, animation: Animation = .automatic) {
        indexAnimationMapper[index] = animation
        if deleteSections?.contains(index) == true {
            deleteSections?.remove(index)
            reloadSections?.insert(index)
            return
        }
        var insertSections = self.insertSections ?? IndexSet()
        insertSections.insert(index)
        self.insertSections = insertSections
    }
    
    public func reloadSection(at index: Int, animation: Animation = .automatic) {
        indexAnimationMapper[index] = animation
        if insertSections?.contains(index) == true {
            return
        }
        if deleteSections?.contains(index) == true {
            deleteSections?.remove(index)
        }
        var reloadSections = self.reloadSections ?? IndexSet()
        reloadSections.insert(index)
        self.reloadSections = reloadSections
    }
    
    public func undoReloadSection(at index: Int) {
        if reloadSections?.contains(index) == true {
            reloadSections?.remove(index)
            indexAnimationMapper.removeValue(forKey: index)
        }
    }
    
    public func deleteSection(at index: Int, animation: Animation = .automatic) {
        indexAnimationMapper[index] = animation
        if insertSections?.contains(index) == true {
            insertSections?.remove(index)
        }
        if reloadSections?.contains(index) == true {
            reloadSections?.remove(index)
        }
        var deleteSections = self.deleteSections ?? IndexSet()
        deleteSections.insert(index)
        self.deleteSections = deleteSections
    }
    
    public func clear() {
        indexAnimationMapper.removeAll()
        reloadRows = Set()
        insertRows = Set()
        deleteRows = Set()
        reloadSections = nil
        insertSections = nil
        deleteSections = nil
    }
}
