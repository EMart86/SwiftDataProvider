//
//  DynamicContentProviderAdapter.swift
//  Pods-LoginExample
//
//  Created by Martin Eberl on 04.12.18.
//

import Foundation

open class DynamicContentProviderAdapter<Content: Comparable>: ContentProviderAdapter {
    
    public enum Operation {
        case append
        case insert(Int)
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
        case .append:
            let section = Section()
            add(section: section)
            return section
        case .insert(let index):
            let section = Section()
            insert(section: section, at: index)
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
