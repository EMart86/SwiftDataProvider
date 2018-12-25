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
        case reload
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
    
    open func commit() {
        context.deleteSections?.forEach { index in
            sections.remove(at: index)
        }
        context.insertSections?.forEach { map in
            guard !sections.isEmpty else {
                sections.append(map.value)
                return
            }
            sections.insert(map.value, at: min(sections.count, map.key))
        }
        sections.enumerated().forEach { [weak self] in
            if let indexPathsAndAnimations = $0.element.indexPaths(for: $0.offset) {
                if let indexPaths = indexPathsAndAnimations.delete, !indexPaths.isEmpty {
                    self?.context.deleteRows.formUnion(indexPaths.keys)
                    self?.context.mergeCell(animations: indexPaths)
                }
                if let indexPaths = indexPathsAndAnimations.insert, !indexPaths.isEmpty {
                    self?.context.insertRows.formUnion(indexPaths.keys)
                    self?.context.mergeCell(animations: indexPaths)
                }
                if let indexPaths = indexPathsAndAnimations.reload, !indexPaths.isEmpty {
                    self?.context.reloadRows.formUnion(indexPaths.keys)
                    self?.context.mergeCell(animations: indexPaths)
                }
            }
            $0.element.clearModification()
        }
        
        delegate?.commit(modifications: context)
        context.clear()
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
    
    open func remove(section: Section) {
        guard let index = index(of: section) else {
            return
        }
        //        sections.remove(at: index)
        context.deleteSection(at: index)
        
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
    func section(_ section: Section, needsReload: Bool) {
        guard let index = index(of: section) else {
            return
        }
        if needsReload {
            context.reloadSection(at: index, animation: .automatic)
        } else {
            context.undoReloadSection(at: index)
        }
    }
    
    func didUpdateRows(for section: Section) {
        updateRows(for: section)
        
        commitIfAutoCommitIsEnabled()
    }
}
