//
//  DynamicContentProviderAdapter.swift
//  Pods-LoginExample
//
//  Created by Martin Eberl on 04.12.18.
//

import Foundation

open class DynamicContentProviderAdapter<Content: Comparable>: ContentProviderAdapter {
    
    public enum Operation {
        case new([String: Any]?)
        case use(Int)
    }
    
    private var contentArray: [Content] = []
    public var sort: ((Content , Content) -> Bool)?
    public var sortSections: ((Section , Section) -> Bool)?
    public var contentSectionizer: ((Content, [Section]?) -> Operation)?
    
    private lazy var firstSection: Section = {
        let section = Section()
        sections.append(section)
        return section
    }()
    
    private func section(for content: Content, readOnly: Bool = false) -> Section? {
        guard let contentSectionizer = contentSectionizer else {
            return firstSection
        }
        let totalSections = self.sections + (context.insertSections?.values.map { $0 } ?? [])
        switch contentSectionizer(content, totalSections) {
        case .new(let context):
            if readOnly {
                return nil
            }
            let section = Section(context: context)
            add(content: content, to: section)
            var sections = self.sections
            sections.append(section)
            
            if let sortSections = sortSections {
                let sortedSections = sections.sorted(by: sortSections)
                if let index = sortedSections.index(where: {
                    section === $0
                }) {
                    insert(section: section, at: index, context: context)
                } else {
                    add(section: section, context: context)
                }
            } else {
                add(section: section, context: context)
            }
            
            commitIfAutoCommitIsEnabled()
            return section
        case .use(let sectionAtIndex):
            let section = totalSections[sectionAtIndex]
            if !readOnly {
                add(content: content, to: section)
            }
            return section
        }
    }
    
    public func add(_ content: Content) {
        _ = section(for: content)
        
        commitIfAutoCommitIsEnabled()
    }
    
    public func remove(_ content: Content) {
        guard let index = contentArray.index(of: content) else {
            return
        }
        contentArray.remove(at: index)
        
        guard let section = self.section(containing: content) else {
            return
        }
        section.delete(row: content)
        if section.totalRows.isEmpty {
            remove(section: section)
        }
        
        commitIfAutoCommitIsEnabled()
    }
    
    public func reload(at indexPath: IndexPath) {
        section(at: indexPath.section)?.reload(at: indexPath.row)
        
        commitIfAutoCommitIsEnabled()
    }
    
    override func updateRows(for section: Section) {
        if let sectionContentUpdate = sectionContentUpdate {
            switch (sectionContentUpdate(section, section.context)) {
            case .nothing:
                break
            case .reload:
                section.setNeedsUpdate(true)
            }
        }
    }
    
    // MARK: - Private
    
    fileprivate func commitIfAutoCommitIsEnabled() {
        guard isAutoCommitEnabled else {
            return
        }
        commit()
    }
    
    private func section<Content: Comparable>(containing content: Content) -> Section? {
        return sections.compactMap { $0 }.first {
            $0.rows.compactMap { $0 as? Content }.first { $0 == content } != nil
        }
    }
    
    private func section(at index: Int) -> Section? {
        guard sections.indices.contains(index) else {
            return nil
        }
        return sections[index]
    }
    
    private func add(content: Content, to section: Section) {
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
}
