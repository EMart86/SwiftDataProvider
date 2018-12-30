//
//  CellModifications.swift
//  DynamicTableView
//
//  Created by Martin Eberl on 07.10.18.
//

import Foundation

public class Modification {
    private(set) var reload: [Int: Any?]?
    private(set) var insert: [Int: Any]?
    private(set) var delete: [Int]?
    private(set) var move: [Int: IndexPath]?
    
    public init(reload: [Int: Any]? = nil,
                insert: [Int: Any]? = nil,
                delete: [Int]? = nil,
                move: [Int: IndexPath]? = nil) {
        self.reload = reload
        self.delete = delete
        self.insert = insert
        self.move = move
    }
    
    private var indexAnimationMapper = [Int: CellModifications.Animation]()
    
    public func insert(content: Any, at index: Int, animation: CellModifications.Animation = .automatic) {
        if removeDeletedRow(index: index) {
            reload(content: content, at: index, animation: animation)
            return
        }
        
        insertAnimation(animation, at: index)
        updateInsertIndexes(below: index)
        
        var insert = self.insert ?? [Int: Any]()
        insert[index] = content
        self.insert = insert
    }
    
    public func reload(content: Any? = nil, at index: Int, animation: CellModifications.Animation = .automatic) {
        guard insert?[index] == nil else {
            return
        }
        
        removeDeletedRow(index: index)
        
        var reload = self.reload ?? [Int: Any?]()
        reload[index] = content
        indexAnimationMapper[index] = animation
        self.reload = reload
    }
    
    public func delete(at index: Int, animation: CellModifications.Animation = .automatic) {
        if removeInsertedRow(index: index) {
            return
        }
        removeReloadedRow(index: index)
        
        var delete = self.delete ?? [Int]()
        delete.append(index)
        indexAnimationMapper[index] = animation
        self.delete = delete
    }
    
    public func move(from index: Int, to indexPath: IndexPath, animation: CellModifications.Animation = .automatic) -> Any? {
        if let object = insert?[index] {
            removeInsertedRow(index: index)
            return object
        }
        removeReloadedRow(index: index)
        removeDeletedRow(index: index)
        
        var move = self.move ?? [Int: IndexPath]()
        move[index] = indexPath
        indexAnimationMapper[index] = animation
        self.move = move
        return nil
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
    
    // MARK: - Private
    
    @discardableResult private func removeDeletedRow(index: Int) -> Bool {
        guard let index = delete?.index(of: index) else {
            return false
        }
        
        delete?.remove(at: index)
        return true
    }
    
    @discardableResult private func removeReloadedRow(index: Int) -> Bool {
        guard reload?.index(forKey: index) != nil else {
            return false
        }
        
        reload?.removeValue(forKey: index)
        return true
    }
    
    @discardableResult private func removeInsertedRow(index: Int) -> Bool {
        return insert?.removeValue(forKey: index) != nil
    }
    
    private func insertAnimation(_ animation: CellModifications.Animation = .automatic, at index: Int) {
        if indexAnimationMapper[index] != nil {
            for key in indexAnimationMapper.keys.sorted().reversed() {
                if key < index {
                    break
                }
                indexAnimationMapper[key + 1] = indexAnimationMapper[key]
            }
        }
        indexAnimationMapper[index] = animation
    }
    
    private func updateInsertIndexes(below index: Int) {
        guard var insert = insert else {
            return
        }
        for key in insert.sorted(by: {$0.key > $1.key}) {
            if key.key < index {
                break
            }
            insert.removeValue(forKey: key.key)
            insert[key.key + 1] = key.value
        }
        self.insert = insert
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
    private(set) var insertSections: [Int: Section]?
    private(set) var deleteSections: IndexSet?
    private(set) var movedSections: [Int: Int]?
    internal var reloadRows: Set<IndexPath>
    internal var insertRows: Set<IndexPath>
    internal var deleteRows: Set<IndexPath>
    internal var movedRows: [IndexPath: (IndexPath, Any)]
    
    public init(reloadRows: Set<IndexPath> =  Set(),
                insertRows: Set<IndexPath> = Set(),
                deleteRows: Set<IndexPath> = Set(),
                movedRows: [IndexPath: (IndexPath, Any)] = [IndexPath: (IndexPath, Any)](),
                reloadSections: IndexSet? = nil,
                insertSections: [Int: Section]? = nil,
                deleteSections: IndexSet? = nil,
                movedSections: [Int: Int]? = nil) {
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
        guard let content = self.movedSections?.removeValue(forKey: sourceIndex) else {
            return
        }
        var movedSections = self.movedSections ?? [Int: Int]()
        movedSections[sourceIndex] = targetIndex
        self.movedSections = movedSections
    }
    
    public func insertSection(_ section: Section, at index: Int, animation: Animation = .automatic) {
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
        var insertSections = self.insertSections ?? [Int: Section]()
        for key in insertSections.keys.sorted().reversed() {
            guard key >= index else {
                break
            }
            guard let section = insertSections[key] else {
                continue
            }
            
            insertSections[key + 1] = section
        }
        insertSections[index] = section
        self.insertSections = insertSections
    }
    
    public func reloadSection(at index: Int, animation: Animation = .automatic) {
        indexAnimationMapper[index] = animation
        if insertSections?.keys.contains(index) == true {
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
        if insertSections?.keys.contains(index) == true {
            insertSections?.removeValue(forKey: index)
            return
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
        movedRows = [IndexPath: (IndexPath, Any)]()
        reloadSections = nil
        insertSections = nil
        deleteSections = nil
        movedSections = nil
    }
}
