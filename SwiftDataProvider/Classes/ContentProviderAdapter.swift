//
//  DynamicContentProviderAdapter.swift
//  DynamicTableView
//
//  Created by Martin Eberl on 13.10.18.
//

import Foundation

public protocol ContentProviderAdapterDelegate: class {
    func reload()
    func commit(modifications: CellModifications)
}

open class ContentProviderAdapter {
    public enum SectionOperation {
        case nothing
        case reload(CellModifications.Animation)
    }
    
    public internal(set) var sections: [Section]
    internal let context = CellModifications()
    public weak var delegate: ContentProviderAdapterDelegate?
    public var sectionContentUpdate: ((Section, [String: Any]?) -> SectionOperation)?
    public var sectionInitializer: ((Section, Int, [String: Any]?) -> Void)?
    public var isAutoCommitEnabled = false
    
    public init(sections: [Section] = [Section]()) {
        self.sections = sections
        sections.forEach {
            $0.delegate = self
            $0.clearModification()
        }
    }
    
    internal var totalSections: [Section] {
        var sections = self.sections
        sections += (context.insertSections?.values.map { $0 } ?? [])
        return sections
    }
    
    private func performUpdate(section: Section, at index: Int) {
        if let indexPathsAndAnimations = section.indexPaths(for: index),
            context.deleteSections?.contains(index).isFalse ?? true {
            if let indexPaths = indexPathsAndAnimations.delete, !indexPaths.isEmpty {
                context.deleteRows.formUnion(indexPaths.keys)
                context.mergeCell(animations: indexPaths)
            }
            if let indexPaths = indexPathsAndAnimations.insert, !indexPaths.isEmpty {
                context.insertRows.formUnion(indexPaths.keys)
                context.mergeCell(animations: indexPaths)
            }
            if let indexPaths = indexPathsAndAnimations.reload, !indexPaths.isEmpty {
                context.reloadRows.formUnion(indexPaths.keys)
                context.mergeCell(animations: indexPaths)
            }
            if let itemsToBeMoved = indexPathsAndAnimations.move, !itemsToBeMoved.isEmpty {
                for (target, (_, object)) in itemsToBeMoved {
                    if let targetSection = sections[safe: target.section] {
                        targetSection.insert(row: object, at: target.row)
                    }
                }
                context.movedRows.merge(itemsToBeMoved) { _, new in return new }
            }
        }
        section.clearModification()
    }
    
    open func commit() {
        if let deleteSections = context.deleteSections {
            deleteSections.forEach { index in
                sections.remove(at: index)
            }
            let modifications = CellModifications(deleteSections: deleteSections)
            modifications.mergeSection(animations: context.animations(for: deleteSections))
            delegate?.commit(modifications: modifications)
            context.clearDeleteSectiosOnly()
        }
        context.insertSections?.forEach { map in
            guard !sections.isEmpty else {
                sections.append(map.value)
                //                performUpdate(section: map.value, at: sections.count - 1)
                return
            }
            let index = min(sections.count, map.key)
            sections.insert(map.value, at: index)
            //            performUpdate(section: map.value, at: index)
        }
        
        sections.enumerated().forEach { [weak self] in
            self?.performUpdate(section: $0.element, at: $0.offset)
        }
        
        delegate?.commit(modifications: context)
        context.clear()
    }
    
    open func rollback() {
        context.clear()
        sections.forEach {
            $0.clearModification()
        }
    }
    
    open func add(section: Section, context: [String: Any]? = nil) {
        //        sections.append(section)
        section.insertPredicate = context?[Section.Keys.predicate] as? NSPredicate
        section.delegate = self
        sectionInitializer?(section, sections.endIndex, context)
        self.context.insertSection(section, at: sections.count - 1)
        
        commitIfAutoCommitIsEnabled()
    }
    
    open func insert(section: Section, at index: Int, context: [String: Any]? = nil) {
        let correctedIndex = min(sections.endIndex, index)
        //        sections.insert(section, at: correctedIndex)
        section.insertPredicate = context?[Section.Keys.predicate] as? NSPredicate
        section.delegate = self
        sectionInitializer?(section, correctedIndex, context)
        self.context.insertSection(section, at: correctedIndex)
        
        commitIfAutoCommitIsEnabled()
    }
    
    open func reload(section: Section) {
        guard let index = index(of: section) else {
            return
        }
        context.reloadSection(at: index)
        
        commitIfAutoCommitIsEnabled()
    }
    
    open func remove(section: Section, animation: CellModifications.Animation = .automatic) {
        guard let index = index(of: section) else {
            return
        }
        //        sections.remove(at: index)
        context.deleteSection(at: index, animation: animation)
        
        commitIfAutoCommitIsEnabled()
    }
    
    open func reload() {
        delegate?.reload()
        context.clear()
    }
    
    // MARK: - private
    
    internal func updateRows(for section: Section) {}
    
    fileprivate func index(of section: Section) -> Int? {
        return sections.index(where: { section === $0 })
    }
    
    fileprivate func commitIfAutoCommitIsEnabled() {
        guard isAutoCommitEnabled else {
            return
        }
        commit()
    }
}

extension ContentProviderAdapter: SectionDelegate {
    func section(_ section: Section, needsReload: Bool, animation: CellModifications.Animation) {
        guard let index = index(of: section) else {
            return
        }
        if needsReload {
            context.reloadSection(at: index, animation: animation)
        } else {
            context.undoReloadSection(at: index)
        }
    }
    
    func didUpdateRows(for section: Section) {
        updateRows(for: section)
        
        commitIfAutoCommitIsEnabled()
    }
}
