//
//  ViewController.swift
//  DynamicTableView
//
//  Created by EMart86 on 10/11/2018.
//  Copyright (c) 2018 EMart86. All rights reserved.
//

import UIKit
import SwiftDataProvider

class ViewController: UITableViewController, RecyclerView {
    
    let viewModel = ViewModel()
    private var dataProvider: SwiftDataProvider?

    override func viewDidLoad() {
        super.viewDidLoad()
        let dataProvider = SwiftDataProvider(recyclerView: self)
        dataProvider.register(cell: UITableViewCell.self, for: TimeModel.self) { cell, content in
            cell.textLabel?.text = content.formattedDate
        }
        dataProvider.register(cell: UITableViewCell.self, for: RandomNumberModel.self) { cell, content in
            cell.textLabel?.text = content.randomNumber
        }
        dataProvider.register(cellReuseIdentifier: "TestCell", as: TestCell.self, for: TestCell.Content.self) { cell, content in
            cell.content = content
        }
        dataProvider.registerHeaderFooter(nib: HeaderView.nib(), as: HeaderView.self, for: HeaderView.Content.self) { header, content in
            header.content = content
        }
        dataProvider.contentAdapter = viewModel.contentAdapter
        self.dataProvider = dataProvider
    }
   
    @IBAction func addItem(_ sender: Any) {
        viewModel.addNewTimeEntry()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class HeaderView: UITableViewHeaderFooterView, XibLoadable {
    static let xibName = "HeaderView"
    
    struct Content {
        
    }
    
    var content: Content? {
        didSet {
            print("")
        }
    }
    
}
