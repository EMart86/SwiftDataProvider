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
    
    private func section(for content: Content) -> (Section, Int) {
        guard let contentSectionizer = contentSectionizer else {
            return (firstSection, 0)
        }
        switch contentSectionizer(content, totalSections) {
        case .new(let context):
            let section = Section(context: context)
            add(content: content, to: section)
            var sections = self.sections
            sections.append(section)
            
            var rowIndex = 0
            if let sortSections = sortSections {
                let sortedSections = sections.sorted(by: sortSections)
                if let index = sortedSections.index(where: {
                    section === $0
                }) {
                    insert(section: section, at: index, context: context)
                    rowIndex = index
                } else {
                    add(section: section, context: context)
                    rowIndex = section.rows.count
                }
            } else {
                add(section: section, context: context)
                rowIndex = section.rows.count
            }
            
            commitIfAutoCommitIsEnabled()
            return (section, rowIndex)
        case .use(let sectionAtIndex):
            let section = totalSections[sectionAtIndex]
            add(content: content, to: section)
            return (section, section.rows.count)
        }
    }
    
    @discardableResult public func add(_ content: Content) -> IndexPath? {
        let value = section(for: content)
        
        commitIfAutoCommitIsEnabled()
        
        guard let sectionIndex = sections.firstIndex(where: { $0 === value.0 }) else {
            return nil
        }
        return IndexPath(row: value.1, section: sectionIndex)
    }
    
    public func move(_ content: Content) -> IndexPath? {
        defer {
            commitIfAutoCommitIsEnabled()
        }
        
        guard let source = remove(content) else {
            return add(content)
        }
        let value = section(for: content)
        value.0.delete(at: value.1)
        guard let targetSection = sections.firstIndex(where: { $0 === value.0 }) else {
            return nil
        }
        let targetIndexPath = IndexPath(row: value.1, section: targetSection)
        sections[source.section].move(from: source.row, to: targetIndexPath)
        return targetIndexPath
    }
    
    @discardableResult public func remove(_ content: Content) -> IndexPath? {
        guard let index = contentArray.index(of: content) else {
            return nil
        }
        contentArray.remove(at: index)
        
        guard let section = self.section(containing: content),
            let sectionIndex = sections.firstIndex(where: { $0 === section }),
            let rowIndex = section.delete(row: content) else {
                return nil
        }
        if section.totalRows.isEmpty {
            remove(section: section)
        }
        
        commitIfAutoCommitIsEnabled()
        return IndexPath(row: rowIndex, section: sectionIndex)
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
        var rows = section.totalRows.compactMap { $0 as? Content }
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
