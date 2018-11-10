//
//  DynamicContentProviderAdapter.swift
//  DynamicTableView
//
//  Created by Martin Eberl on 13.10.18.
//

import Foundation

public protocol ContentProviderAdapterDelegate: class {
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
            if let indexPaths = $0.element.indexPaths(for: $0.offset) {
                if let indexPaths = indexPaths.delete {
                    context.deleteRows.formUnion(indexPaths)
                }
                if let indexPaths = indexPaths.insert {
                    context.insertRows.formUnion(indexPaths)
                }
                if let indexPaths = indexPaths.reload {
                    context.reloadRows.formUnion(indexPaths)
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

open class DynamicContentProviderAdapter<Content: Comparable>: ContentProviderAdapter {
    
    public enum Operation {
        case new
        case use(Int)
    }
    
    private var contentArray: [Content] = []
    public var sort: ((Content , Content) -> Bool)?
    public var contentSectionizer: ((Content, [Section]?) -> Operation)?
    
    private lazy var firstSection: Section = {
        let section = Section()
        sections.append(section)
        return section
    }()
    
    private func section(for content: Content) -> Section {
        guard let contentSectionizer = contentSectionizer else {
            return firstSection
        }
        switch (contentSectionizer(content, sections)) {
        case .new:
            let section = Section()
            add(section: section)
            return section
        case .use(let sectionAtIndex):
            return sections[sectionAtIndex]
        }
    }
    
    public func add(_ content: Content) {
        let section = self.section(for: content)
        var rows = section.rows.compactMap { $0 as? Content }
        rows.append(content)
        if let sort = sort {
            rows.sort { sort($0, $1) }
        }
        
        guard let index = rows.index(of: content) else {
            return
        }
        
        contentArray.append(content)
        section.insert(row: content, at: index)
    }
    
    public func remove(_ content: Content) {
        guard let index = contentArray.index(of: content) else {
            return
        }
        contentArray.remove(at: index)
        section(for: content).delete(row: content)
    }
    
    // MARK: - Private
    
    override func updateRows(for section: Section) {
        if let sectionContentUpdate = sectionContentUpdate {
            switch (sectionContentUpdate(section)) {
            case .nothing:
                break
            case .reload:
                section.setNeedsUpdate(true)
            }
        }
    }
}

