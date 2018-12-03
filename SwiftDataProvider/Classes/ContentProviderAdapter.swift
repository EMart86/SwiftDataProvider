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
    fileprivate let context = CellModifications()
    public weak var delegate: ContentProviderAdapterDelegate?
    public var sectionContentUpdate: ((Section) -> SectionOperation)?
    public var sectionInitializer: ((Section) -> Void)?
    public var isAutoCommitEnabled = false
    
    public init(sections: [Section] = [Section]()) {
        self.sections = sections
        sections.forEach {
            $0.delegate = self
            $0.clearContext()
        }
    }
    
    open func commit() {
        sections.enumerated().forEach {
            if let indexPathsAndAnimations = $0.element.indexPaths(for: $0.offset) {
                if let indexPaths = indexPathsAndAnimations.delete {
                    context.deleteRows.formUnion(indexPaths.keys)
                    context.mergeCell(animations: indexPaths)
                }
                if let indexPaths = indexPathsAndAnimations.insert {
                    context.insertRows.formUnion(indexPaths.keys)
                    context.mergeCell(animations: indexPaths)
                }
                if let indexPaths = indexPathsAndAnimations.reload {
                    context.reloadRows.formUnion(indexPaths.keys)
                    context.mergeCell(animations: indexPaths)
                }
            }
            $0.element.clearContext()
        }
        delegate?.commit(modifications: context)
        context.clear()
    }
    
    open func add(section: Section) {
        sections.append(section)
        section.delegate = self
        sectionInitializer?(section)
        context.insertSection(at: sections.count - 1)
        
        commitIfAutoCommitIsEnabled()
    }
    
    open func insert(section: Section, at index: Int) {
        sections.insert(section, at: index)
        section.delegate = self
        sectionInitializer?(section)
        context.insertSection(at: index)
        
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
        sections.remove(at: index)
        context.deleteSection(at: index)
        
        commitIfAutoCommitIsEnabled()
    }
    
    open func reload() {
        delegate?.reload()
        context.clear()
    }
    
    // MARK: - private
    
    fileprivate func updateRows(for section: Section) {}
    
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
