//
//  DataProvider.swift
//  DynamicTableView
//
//  Created by Martin Eberl on 07.10.18.
//

import Foundation

open class SwiftDataProvider: NSObject, DataSource, UITableViewDataSource {
    private var registeredCellsForContentType = [String: Assemblable]()
    private var registeredHeaderFooterForContentType = [String: AssemblableHeaderFooter]()
    
    public weak var contentAdapter: ContentProviderAdapter? {
        didSet {
            contentAdapter?.delegate = self
        }
    }
    
    fileprivate weak var recyclerView: RecyclerView?
    
    public init(recyclerView: RecyclerView) {
        self.recyclerView = recyclerView
        super.init()
        recyclerView.dataSource = self
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
    
    // MARK: - Public
    
    public func register<Content, TableViewCell: UITableViewCell>(cell: TableViewCell.Type, for content: Content.Type, assemble: @escaping ((UITableViewCell, Content) -> Void)) {
        let className = String.string(from: content)
        recyclerView?.register(cell, forCellReuseIdentifier: className)
        registeredCellsForContentType[className] = Assemble(reuseIdentifier: className, cellType: cell, assembler: assemble)
    }
    
    public func register<Content, TableViewCell: UITableViewCell>(cellReuseIdentifier: String, as cell: TableViewCell.Type, for content: Content.Type, assemble: @escaping ((TableViewCell, Content) -> Void)) {
        let className = String.string(from: content)
        registeredCellsForContentType[className] = Assemble(reuseIdentifier: cellReuseIdentifier, cellType: cell, assembler: assemble)
    }
    
    public func dequeueReusableCell<Content>(for content: Content) -> UITableViewCell? {
        let className = String.string(from: type(of: content))
        let assembler = registeredCellsForContentType[className]
        guard let cell = recyclerView?.dequeueReusableCell(withIdentifier: assembler?.reuseIdentifier ?? className) else {
            return nil
        }
        assembler?.assemble(cell: cell, with: content)
        return cell
    }
    
    public func registerHeaderFooter<Content, TableHeaderView: UITableViewHeaderFooterView>(view: TableHeaderView.Type, for content: Content.Type, assemble: @escaping ((TableHeaderView, Content) -> Void)) {
        let className = String.string(from: content)
        recyclerView?.register(view, forHeaderFooterViewReuseIdentifier: className)
        registeredHeaderFooterForContentType[className] = AssembleHeaderFooter(reuseIdentifier: className, viewType: view, assembler: assemble)
    }
    
    public func dequeueReusableHeaderFooterView<Content>(for content: Content) -> UITableViewHeaderFooterView? {
        let className = String.string(from: type(of: content))
        let assembler = registeredHeaderFooterForContentType[className]
        guard let cell = recyclerView?.dequeueReusableHeaderFooterView(withIdentifier: assembler?.reuseIdentifier ?? className) else {
            return nil
        }
        assembler?.assemble(view: cell, with: content)
        return cell
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
        return dequeueReusableCell(for: content) ?? UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeader(at: section)
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sectionFooter(at: section)
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
