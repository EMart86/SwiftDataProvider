//
//  ViewModel.swift
//  DynamicTableView_Example
//
//  Created by Martin Eberl on 11.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import SwiftDataProvider

enum Type {
    case dynamic
    case `static`
    
    var initialize: ContentProviderAdapter {
        switch self {
        case .dynamic:
            let contentAdapter = DynamicContentProviderAdapter<TimeModel>()
            contentAdapter.sort = { $0 < $1 }
            contentAdapter.sectionContentUpdate = { section in
                section.set(header: "\(section.rows.count) Items")
                return .reload
            }
            contentAdapter.sectionInitializer = { section in
                section.set(header: "\(section.rows.count) Items")
            }
            contentAdapter.contentSectionizer = { content, sections in
                guard let last = sections?.last else {
                    return .new
                }
                let rows = last.rows.compactMap { $0 as? TimeModel }
                if let timeInterval = rows.first?.date.timeIntervalSince(content.date),
                    timeInterval < -60  {
                    return .new
                }
                return .use((sections?.count ?? 1) - 1)
            }
            return contentAdapter
        case .static:
            let section = Section()
            section.set(header: HeaderView.Content())
            for _ in 0..<3 {
                switch Int.random(in: 0..<3) {
                case 1:
                    section.add(row: RandomNumberModel())
                case 2:
                    section.add(row: TestCell.Content(titel: "\(Double.random(in: 0..<12345))"))
                default:
                    section.add(row: TimeModel(date: Date(timeIntervalSinceNow: Double.random(in: -30..<30))))
                }
            }
            return ContentProviderAdapter(sections: [section])
        }
    }
    
    func addEntry(contentAdapter: ContentProviderAdapter, commit: Bool = true) {
        switch self {
        case .dynamic:
            guard let contentAdapter = contentAdapter as? DynamicContentProviderAdapter<TimeModel> else {
                return
            }
            contentAdapter.add(TimeModel(date: Date(timeIntervalSinceNow: Double.random(in: -30..<30))))
        case .static:
            let section = Section()
            section.set(header: "Test")
            contentAdapter.add(section: section)
            for _ in 0..<3 {
                switch Int.random(in: 0..<3) {
                case 1:
                    section.add(row: RandomNumberModel())
                case 2:
                    section.add(row: TestCell.Content(titel: "\(Double.random(in: 0..<12345))"))
                default:
                    section.add(row: TimeModel(date: Date(timeIntervalSinceNow: Double.random(in: -30..<30))))
                }
            }
        }
        if commit {
            contentAdapter.commit()
        }
    }
}

class ViewModel {
    let contentAdapter: ContentProviderAdapter
    let type: Type = .static
    init() {
        contentAdapter = type.initialize
    }
    
    func addNewTimeEntry() {
        type.addEntry(contentAdapter: contentAdapter)
    }
}

extension Double {
    static func random(in range: Range<Double>) -> Double {
        var upper = range.upperBound < 0 ? (-1) * range.upperBound : range.upperBound
        var lower = range.lowerBound < 0 ? (-1) * range.lowerBound : range.lowerBound
        return Double(arc4random_uniform(UInt32(upper + lower))) + range.lowerBound
    }
}

extension Int {
    static func random(in range: Range<Int>) -> Int {
        var upper = range.upperBound < 0 ? (-1) * range.upperBound : range.upperBound
        var lower = range.lowerBound < 0 ? (-1) * range.lowerBound : range.lowerBound
        return Int(arc4random_uniform(UInt32(upper + lower))) + range.lowerBound
    }
}
