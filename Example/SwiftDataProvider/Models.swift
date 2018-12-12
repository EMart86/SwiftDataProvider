//
//  Model.swift
//  DynamicTableView_Example
//
//  Created by Martin Eberl on 11.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//
import SwiftDataProvider
import Foundation

protocol BaseCompareable: Comparable {
}

struct RandomNumberModel: BaseCompareable {
    static func == (lhs: RandomNumberModel, rhs: RandomNumberModel) -> Bool {
        return lhs.randomNumber == rhs.randomNumber
    }
    
    static func < (lhs: RandomNumberModel, rhs: RandomNumberModel) -> Bool {
        return lhs.randomNumber < rhs.randomNumber
    }
    
    let randomNumber: String
    
    init(randomNumber: String = "\(arc4random())") {
        self.randomNumber = randomNumber
    }
}

@objc class TimeModel: NSObject, BaseCompareable {
    
    static func == (lhs: TimeModel, rhs: TimeModel) -> Bool {
        return lhs.date == rhs.date
    }
    
    static func < (lhs: TimeModel, rhs: TimeModel) -> Bool {
        return lhs.date < rhs.date
    }
    
    @objc dynamic let date: Date
    
    init(date: Date = Date()) {
        self.date = date
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        return formatter.string(from: date)
    }
}
