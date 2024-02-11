//
//  DataProvider.swift
//  DynamicTableView
//
//  Created by Martin Eberl on 07.10.18.
//

import UIKit

open class SwiftDataProvider: NSObject, UITableViewDataSource, UITableViewDelegate {
    private var registeredCellsForContentType = [String: Assemblable]()
    private var registeredHeaderFooterForContentType = [String: AssemblableHeaderFooter]()
    
    public weak var tableViewDelegate: UITableViewDelegate?
    public weak var tableViewDataSource: UITableViewDataSource?
    public weak var contentAdapter: ContentProviderAdapter? {
        didSet {
            contentAdapter?.delegate = self
            recyclerView?.reloadData()
        }
    }
    
    fileprivate weak var recyclerView: RecyclerView?
    
    public init(recyclerView: RecyclerView) {
        self.recyclerView = recyclerView
        super.init()
        recyclerView.dataSource = self
        tableViewDelegate = recyclerView.delegate
        tableViewDataSource = recyclerView.dataSource
        recyclerView.delegate = self
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
    
    func sectionHeader(at section: Int) -> TypeAndObject? {
        return self.section(at: section)?.header
    }
    
    func sectionFooter(at section: Int) -> TypeAndObject? {
        return self.section(at: section)?.footer
    }
    
    // MARK: - Public
    
    public func register<Content, TableViewCell: UITableViewCell>(cell: TableViewCell.Type, for content: Content.Type, assemble: @escaping ((TableViewCell, Content) -> Void)) {
        let className = String.string(from: content)
        let reuseIdentifier = String.string(from: cell)
        recyclerView?.register(cell, forCellReuseIdentifier: reuseIdentifier)
        registeredCellsForContentType[className] = Assemble(reuseIdentifier: reuseIdentifier, cellType: cell, assembler: assemble)
    }
    
    public func register<Content, TableViewCell: UITableViewCell>(nib: UINib?, as cell: TableViewCell.Type, for content: Content.Type, assemble: @escaping ((TableViewCell, Content) -> Void)) {
        let className = String.string(from: content)
        let reuseIdentifier = String.string(from: cell)
        recyclerView?.register(nib, forCellReuseIdentifier: reuseIdentifier)
        registeredCellsForContentType[className] = Assemble(reuseIdentifier: reuseIdentifier, cellType: cell, assembler: assemble)
    }
    
    public func register<Content, TableViewCell: UITableViewCell>(cellReuseIdentifier: String, as cell: TableViewCell.Type, for content: Content.Type, assemble: @escaping ((TableViewCell, Content) -> Void)) {
        let className = String.string(from: content)
        registeredCellsForContentType[className] = Assemble(reuseIdentifier: cellReuseIdentifier, cellType: cell, assembler: assemble)
    }
    
    public func dequeueReusableCell<Content>(for content: Content, as className: String) -> UITableViewCell? {
        let assembler = registeredCellsForContentType[className]
        guard let cell = recyclerView?.dequeueReusableCell(withIdentifier: assembler?.reuseIdentifier ?? className) else {
            return nil
        }
        assembler?.assemble(cell: cell, with: content)
        return cell
    }
    
    public func registerHeaderFooter<Content, TableHeaderView: UITableViewHeaderFooterView>(view: TableHeaderView.Type, for content: Content.Type, assemble: @escaping ((TableHeaderView, Content) -> Void)) {
        let className = String.string(from: content)
        let reuseIdentifier = String.string(from: view)
        recyclerView?.register(view, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        registeredHeaderFooterForContentType[className] = AssembleHeaderFooter(reuseIdentifier: reuseIdentifier, viewType: view, assembler: assemble)
    }
    
    public func registerHeaderFooter<Content, TableHeaderView: UITableViewHeaderFooterView>(nib: UINib, as view: TableHeaderView.Type, for content: Content.Type, assemble: @escaping ((TableHeaderView, Content) -> Void)) {
        let className = String.string(from: content)
        let reuseIdentifier = String.string(from: view)
        recyclerView?.register(nib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        registeredHeaderFooterForContentType[className] = AssembleHeaderFooter(reuseIdentifier: reuseIdentifier, viewType: view, assembler: assemble)
    }
    
    public func dequeueReusableHeaderFooterView<Content>(for content: Content, as className: String) -> UITableViewHeaderFooterView? {
        if className == String(describing: type(of: className)) {
            let view = UITableViewHeaderFooterView()
            view.textLabel?.text = content as! String
            return view
        }
        let assembler = registeredHeaderFooterForContentType[className]
        guard let view = recyclerView?.dequeueReusableHeaderFooterView(withIdentifier: assembler?.reuseIdentifier ?? className) else {
            return nil
        }
        assembler?.assemble(view: view, with: content)
        return view
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
        return dequeueReusableCell(for: content, as: content is String ? "String" : String.string(from: content)) ?? UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = sectionHeader(at: section) else {
            return nil
        }
        return dequeueReusableHeaderFooterView(for: header.object, as: header.type)
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = sectionFooter(at: section) else {
            return nil
        }
        return dequeueReusableHeaderFooterView(for: footer.object, as: footer.type)
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard tableViewDataSource !== self else {
            return false
        }
        return tableViewDataSource?.tableView?(tableView, canEditRowAt: indexPath) ?? false
    }
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        guard tableViewDataSource !== self else {
            return false
        }
        return tableViewDataSource?.tableView?(tableView, canMoveRowAt: indexPath) ?? false
    }
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {return nil}
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {return 0}
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {}
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {}
    
    // MARK: - UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableViewDelegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        tableViewDelegate?.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        tableViewDelegate?.tableView?(tableView, willDisplayFooterView: view, forSection: section)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableViewDelegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        tableViewDelegate?.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        tableViewDelegate?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewDelegate?.tableView?(tableView, heightForRowAt: indexPath) ?? UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let _ = sectionHeader(at: section) else {
            return 0
        }
        return tableViewDelegate?.tableView?(tableView, heightForHeaderInSection: section) ?? UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let _ = sectionFooter(at: section) else {
            return 0
        }
        return tableViewDelegate?.tableView?(tableView, heightForFooterInSection: section) ?? UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewDelegate?.tableView?(tableView, estimatedHeightForRowAt: indexPath) ?? 44
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return tableViewDelegate?.tableView?(tableView, estimatedHeightForHeaderInSection: section) ?? 20
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return tableViewDelegate?.tableView?(tableView, estimatedHeightForFooterInSection: section) ?? 20
    }
    
    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        tableViewDelegate?.tableView?(tableView, accessoryButtonTappedForRowWith: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return tableViewDelegate?.tableView?(tableView, shouldHighlightRowAt: indexPath) ?? true
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        tableViewDelegate?.tableView?(tableView, didHighlightRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        tableViewDelegate?.tableView?(tableView, didUnhighlightRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return tableViewDelegate?.tableView?(tableView, willSelectRowAt: indexPath) ?? indexPath
    }
    
    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return tableViewDelegate?.tableView?(tableView, willDeselectRowAt: indexPath) ?? indexPath
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewDelegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableViewDelegate?.tableView?(tableView, didDeselectRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return tableViewDelegate?.tableView?(tableView, editingStyleForRowAt: indexPath) ?? .none
    }
    
    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return tableViewDelegate?.tableView?(tableView, titleForDeleteConfirmationButtonForRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return tableViewDelegate?.tableView?(tableView, editActionsForRowAt: indexPath)
    }
    
    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return tableViewDelegate?.tableView?(tableView, leadingSwipeActionsConfigurationForRowAt: indexPath)
    }
    
    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return tableViewDelegate?.tableView?(tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return tableViewDelegate?.tableView?(tableView, shouldIndentWhileEditingRowAt: indexPath) ?? false
    }
    
    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        tableViewDelegate?.tableView?(tableView, willBeginEditingRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        tableViewDelegate?.tableView?(tableView, didEndEditingRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return tableViewDelegate?.tableView?(tableView, targetIndexPathForMoveFromRowAt: sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath) ?? proposedDestinationIndexPath
    }
    
    public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return tableViewDelegate?.tableView?(tableView, indentationLevelForRowAt: indexPath) ?? 0
    }
    
    public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return tableViewDelegate?.tableView?(tableView, shouldShowMenuForRowAt: indexPath) ?? false
    }
    
    public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return tableViewDelegate?.tableView?(tableView, canPerformAction: action, forRowAt: indexPath, withSender: sender) ?? false
    }
    
    public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        tableViewDelegate?.tableView?(tableView, performAction: action, forRowAt: indexPath, withSender: sender)
    }
    
    @available(iOS 9.0, *)
    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return tableViewDelegate?.tableView?(tableView, canFocusRowAt: indexPath) ?? true
    }
    
    @available(iOS 9.0, *)
    public func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        return tableViewDelegate?.tableView?(tableView, shouldUpdateFocusIn: context) ?? true
    }
    
    @available(iOS 9.0, *)
    public func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        tableViewDelegate?.tableView?(tableView, didUpdateFocusIn: context, with: coordinator)
    }
    
    @available(iOS 9.0, *)
    public func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        return tableViewDelegate?.indexPathForPreferredFocusedView?(in: tableView)
    }
    
    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        return tableViewDelegate?.tableView?(tableView, shouldSpringLoadRowAt: indexPath, with: context) ?? false
    }
}

extension SwiftDataProvider: ContentProviderAdapterDelegate {
    public func commit(modifications: CellModifications) {
        recyclerView?.update(modifications: modifications)
    }
    
    public func reload() {
        recyclerView?.reloadData()
    }
}
