//
//  DataSource.swift
//  DynamicTableView
//
//  Created by Martin Eberl on 07.10.18.
//

import UIKit

protocol DataSource {
    var numberOfSections: Int { get }
    func numberOfItems(at section: Int) -> Int
    func item(at indexPath: IndexPath) -> Any?
    func sectionHeader<Header>(at section: Int) -> Header?
    func sectionFooter<Footer>(at section: Int) -> Footer?
}
