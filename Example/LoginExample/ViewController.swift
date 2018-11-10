//
//  ViewController.swift
//  LoginExample
//
//  Created by Martin Eberl on 10.11.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import SwiftDataProvider

class ViewController: UITableViewController, RecyclerView {
    
    private var dataProvider: SwiftDataProvider?
    private var viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataProvider = SwiftDataProvider(recyclerView: self)
        dataProvider.register(nib: TextEnterCell.nib(), as: TextEnterCell.self, for: TextEnterCell.Content.self) { cell, content in
            cell.content = content
        }
        dataProvider.registerHeaderFooter(nib: HeaderView.nib(), as: HeaderView.self, for: HeaderView.HeaderContent.self) { _, _ in }
        dataProvider.registerHeaderFooter(nib: FooterView.nib(), as: FooterView.self, for: FooterView.FooterContent.self) { view, content in
            view.content = content
        }
        dataProvider.contentAdapter = viewModel.contentAdapter
        self.dataProvider = dataProvider
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.onChangeToLoginClicked()
    }
}
