//
//  ViewModel.swift
//  LoginExample
//
//  Created by Martin Eberl on 10.11.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import SwiftDataProvider

class ViewModel {
    let contentAdapter: ContentProviderAdapter
    let section = Section()
    var date: Date?
    var pickerIsShown = false
    
    init() {
        contentAdapter = ContentProviderAdapter()
        contentAdapter.add(section: section)
        contentAdapter.commit()
    }
    
    func togglePicker() {
        if pickerIsShown {
            hidePicker()
        } else {
            showPicker()
        }
    }
    
    func showPicker() {
        pickerIsShown = true
        section.clear()
        section.add(row: "Hello")
        section.add(row: "World")
        section.add(row: DateSelectionCell.Content { self.date = $0 }, animation: .fade)
        contentAdapter.commit()
    }
    
    func hidePicker() {
        pickerIsShown = false
        section.clear()
        section.add(row: "Hello2")
        section.add(row: "World2")
        section.add(row: CellData(date: date))
        contentAdapter.commit()
    }
}
