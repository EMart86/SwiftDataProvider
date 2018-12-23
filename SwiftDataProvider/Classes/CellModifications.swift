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
    
    private var indexAnimationMapper = [Int: CellModifications.Animation]()
    
    public func insert(at index: Int, animation: CellModifications.Animation = .automatic) {
        if indexAnimationMapper[index] != nil {
            for key in indexAnimationMapper.keys.sorted().reversed() {
                if key < index {
                    break
                }
                indexAnimationMapper[key + 1] = indexAnimationMapper[key]
            }
        }
        if let _index = delete?.index(of: index) {
            delete?.remove(at: _index)
            var reload = self.reload ?? [Int]()
            reload.append(index)
            indexAnimationMapper[index] = animation
            self.reload = reload
            return
        }
        var insert = self.insert ?? [Int]()
        for key in insert.sorted().reversed() {
            if key < index {
                break
            }
            insert.remove(at: key)
            insert.append(key + 1)
        }
        if !insert.contains(index) {
            insert.append(index)
        }
        indexAnimationMapper[index] = animation
        self.insert = insert
    }
    
    public func reload(at index: Int, animation: CellModifications.Animation = .automatic) {
        if insert?.contains(index) == true {
            return
        }
        if let _index = delete?.index(of: index) {
            delete?.remove(at: _index)
        }
        var reload = self.reload ?? [Int]()
        reload.append(index)
        indexAnimationMapper[index] = animation
        self.reload = reload
    }
    
    public func delete(at index: Int, animation: CellModifications.Animation = .automatic) {
        if let _index = insert?.index(of: index) {
            insert?.remove(at: _index)
        }
        if let _index = reload?.index(of: index) {
            reload?.remove(at: _index)
        }
        var delete = self.delete ?? [Int]()
        delete.append(index)
        indexAnimationMapper[index] = animation
        self.delete = delete
    }
    
    public func clear() {
        reload = nil
        insert = nil
        delete = nil
        indexAnimationMapper.removeAll()
    }
    
    public func animation(for index: Int) -> CellModifications.Animation? {
        return indexAnimationMapper[index]
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
    private(set) var movedSections: IndexSet?
    internal var reloadRows: Set<IndexPath>
    internal var insertRows: Set<IndexPath>
    internal var deleteRows: Set<IndexPath>
    internal var movedRows: Set<IndexPath>
    
    public init(reloadRows: Set<IndexPath> =  Set(),
                insertRows: Set<IndexPath> = Set(),
                deleteRows: Set<IndexPath> = Set(),
                movedRows: Set<IndexPath> = Set(),
                reloadSections: IndexSet? = nil,
                insertSections: IndexSet? = nil,
                deleteSections: IndexSet? = nil,
                movedSections: IndexSet? = nil) {
        self.reloadRows = reloadRows
        self.deleteRows = deleteRows
        self.insertRows = insertRows
        self.movedRows = movedRows
        self.reloadSections = reloadSections
        self.deleteSections = deleteSections
        self.insertSections = insertSections
        self.movedSections = movedSections
    }
    
    private var indexAnimationMapper = [Int: Animation]()
    private var cellAnimationMapper = [IndexPath: Animation]()
    
    public func mergeCell(animations: [IndexPath: Animation]) {
        cellAnimationMapper.merge(animations) { _, new in
            return new
        }
    }
    
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
    
    public func animations(for indexPaths: [IndexPath]) -> [Animation: [IndexPath]] {
        var mapper = [Animation: [IndexPath]]()
        for indexPath in indexPaths {
            if let animation = cellAnimationMapper[indexPath] {
                var indexPaths = mapper[animation] ?? [IndexPath]()
                indexPaths.append(indexPath)
                mapper[animation] = indexPaths
            }
        }
        return mapper
    }
    
    public func movedSection(from sourceIndex: Int, to targetIndex: Int?, animation: Animation = .automatic) {
        guard let targetIndex = targetIndex else {
            deleteSection(at: sourceIndex, animation: animation)
            return
        }
        guard let content = self.movedSections?.remove(sourceIndex) else {
            return
        }
        var movedSections = self.movedSections ?? IndexSet()
        self.movedSections = movedSections
    }
    
    public func insertSection(at index: Int, animation: Animation = .automatic) {
        if indexAnimationMapper[index] != nil {
            for key in indexAnimationMapper.keys.sorted().reversed() {
                if key < index {
                    break
                }
                indexAnimationMapper[key + 1] = indexAnimationMapper[key]
            }
        }
        indexAnimationMapper[index] = animation
        if deleteSections?.contains(index) == true {
            deleteSections?.remove(index)
            reloadSections?.insert(index)
            return
        }
        var insertSections = self.insertSections ?? IndexSet()
        for key in insertSections.sorted().reversed() {
            if key < index {
                break
            }
            insertSections.insert(key + 1)
        }
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
        cellAnimationMapper.removeAll()
        indexAnimationMapper.removeAll()
        reloadRows = Set()
        insertRows = Set()
        deleteRows = Set()
        reloadSections = nil
        insertSections = nil
        deleteSections = nil
    }
}
