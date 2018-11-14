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
    
    struct Content: Comparable {
        static func < (lhs: DateSelectionCell.Content, rhs: DateSelectionCell.Content) -> Bool {
            return false
        }
        
        static func == (lhs: DateSelectionCell.Content, rhs: DateSelectionCell.Content) -> Bool {
            return true
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

