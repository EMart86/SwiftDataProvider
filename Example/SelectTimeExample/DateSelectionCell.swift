//
//  DateSelectionCell.swift
//  SelectTimeExample
//
//  Created by Martin Eberl on 14.11.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

final class DateSelectionCell: UITableViewCell, XibLoadable {
    static let xibName = "DateSelectionCell"

    @IBOutlet weak var picker: UIDatePicker!
    var content: Content?
    
    class Content {
        init(callback: @escaping (Date) -> Void) {
            self.callback = callback
        }
        let callback: (Date) -> Void
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        picker.addTarget(self, action: #selector(pickerSelected(_:)), for: .valueChanged)
    }
    
    @objc private func pickerSelected(_ sender: Any) {
        content?.callback(picker.date)
    }
}

