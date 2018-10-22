//
//  TestCell.swift
//  DynamicTableView_Example
//
//  Created by Martin Eberl on 21.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

final class TestCell: UITableViewCell {
    struct Content: Comparable {
        static func < (lhs: TestCell.Content, rhs: TestCell.Content) -> Bool {
            return lhs.titel < rhs.titel
        }
        
        let titel: String
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var content: Content? {
        didSet {
            titleLabel.text = content?.titel
        }
    }
}
