//
//  ViewController.swift
//  SelectTimeExample
//
//  Created by Martin Eberl on 14.11.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import SwiftDataProvider

struct CellData: Comparable {
    static func < (lhs: CellData, rhs: CellData) -> Bool {
        return false
    }
    
    let date: Date?
    
    var formattedDate: String {
        guard let date = date else {
            return "-"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: date)
    }
}

class ViewController: UITableViewController, RecyclerView {
    
    private var dataProvider: SwiftDataProvider?
    private var viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        let dataProvider = SwiftDataProvider(recyclerView: self)
        dataProvider.register(cell: UITableViewCell.self, for: String.self) { cell, content in
            cell.textLabel?.text = content
        }
        dataProvider.register(cell: UITableViewCell.self, for: CellData.self) { cell, content in
            cell.textLabel?.text = content.formattedDate
        }
        dataProvider.register(nib: DateSelectionCell.nib(), as: DateSelectionCell.self, for: DateSelectionCell.Content.self) { cell, content in
            cell.content = content
        }
        dataProvider.contentAdapter = viewModel.contentAdapter
        self.dataProvider = dataProvider
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.hidePicker()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.togglePicker()
    }
}
