//
//  DataProvider.swift
//  DynamicTableView
//
//  Created by Martin Eberl on 07.10.18.
//

import Foundation

protocol SectionDelegate: class {
    func section(_ section: Section, needsReload: Bool)
    func didUpdateRows(for section: Section)
}

open class Section {
    open var header: Any?
    open var footer: Any?
    open var rows: [Any]
    
    public init(header: Any? = nil, footer: Any? = nil, rows: [Any] = []) {
        self.header = header
        self.footer = footer
        self.rows = rows
    }
    
    internal weak var delegate: SectionDelegate?
    internal var context = Modification()

    open func add<Content: Comparable>(row: Content) {
        rows.append(row)
        context.insert(at: rows.count - 1)
        delegate?.didUpdateRows(for: self)
    }
    
    open func insert<Content: Comparable>(row: Content, at index: Int) {
        rows.insert(row, at: index)
        context.insert(at: index)
        delegate?.didUpdateRows(for: self)
    }
    
    open func delete<Content: Comparable>(row: Content) {
        guard let index = rows.index(where: { ($0 as? Content) == row } ) else {
            return
        }
        self.rows.remove(at: index)
        context.delete(at: index)
        delegate?.didUpdateRows(for: self)
    }
    
    open func reload(at index: Int) {
        context.reload(at: index)
    }
    
    open func indexPaths(for section: Int) -> (reload: [IndexPath]?, delete: [IndexPath]?, insert: [IndexPath]?)? {
        let reload = context.reload?.compactMap { IndexPath(row: $0, section: section) }
        let delete = context.delete?.compactMap { IndexPath(row: $0, section: section) }
        let insert = context.insert?.compactMap { IndexPath(row: $0, section: section) }
        
        if reload == nil && delete == nil && insert == nil {
            return nil
        }
        
        return (reload: reload, delete: delete, insert: insert)
    }
    
    open func clear() {
        context.clear()
    }
    
    open func setNeedsUpdate(_ needsUpdate: Bool) {
        delegate?.section(self, needsReload: needsUpdate)
    }
}

open class SwiftDataProvider<Header, Footer>: NSObject, DataSource, UITableViewDataSource {
    public var cellProvider: ((Any?, IndexPath) -> UITableViewCell)?
    public var cellAssembler: ((Any?, UITableViewCell) -> Void)?
    var sectionHeader: ((Section) -> Header)?
    var sectionHeaderViewProvider: ((Header?, Int) -> UIView)?
    var sectionFooterViewProvider: ((Footer?, Int) -> UIView)?
    
    public weak var contentAdapter: ContentProviderAdapter? {
        didSet {
            contentAdapter?.delegate = self
        }
    }
    
    fileprivate weak var recyclerView: RecyclerView?
    
    public init(recyclerView: RecyclerView) {
        self.recyclerView = recyclerView
        super.init()
    }
    
    var numberOfSections: Int {
        return contentAdapter?.sections.count ?? 0
    }
    
    func numberOfItems(at section: Int) -> Int {
        return contentAdapter?.sections[section].rows.count ?? 0
    }
    
    func item(at indexPath: IndexPath) -> Any? {
        guard let section = section(at: indexPath.section), section.rows.indices.contains(indexPath.row) else {
            return nil
        }
        return section.rows[indexPath.row]
    }
    
    func sectionHeader<Header>(at section: Int) -> Header? {
        return self.section(at: section)?.header as? Header
    }
    
    func sectionFooter<Footer>(at section: Int) -> Footer? {
        return self.section(at: section)?.footer as? Footer
    }
    
    // MARK: - Helper
    
    private func section(at index: Int) -> Section? {
        guard let sections = contentAdapter?.sections,
            sections.indices.contains(index) else {
            return nil
        }
        return contentAdapter?.sections[index]
    }
    
    private func section<Content: Equatable>(containing content: Content) -> Section? {
        return contentAdapter?.sections.first {
            return $0.rows.compactMap { $0 as? Content }.contains(where: { $0 == content })
        }
    }
    
    // MARK -    
    // MARK: TableView DataSource
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems(at: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let content = item(at: indexPath) else {
            return UITableViewCell()
        }
        let cell = self.recyclerView?.dequeueReusableCell(for: content) ?? cellProvider?(content, indexPath) ?? UITableViewCell()
        cellAssembler?(content, cell)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeaderViewProvider?(sectionHeader(at: section), section)
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sectionFooterViewProvider?(sectionFooter(at: section), section)
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = self.section(at: section), let title = section.header as? String else {
            return nil
        }
        return title
    }
    
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let section = self.section(at: section), let footer = section.footer as? String else {
            return nil
        }
        return footer
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {return false}
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {return false}
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {return nil}
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {return 0}
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {}
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {}
}

extension SwiftDataProvider: ContentProviderAdapterDelegate {
    public func commit(modifications: CellModifications) {
        recyclerView?.update(modifications: modifications)
    }
}
