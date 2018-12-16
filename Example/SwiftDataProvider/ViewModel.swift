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
            contentAdapter.sort = { $0 > $1 }
            contentAdapter.sortSections = {
                guard let first = $0.rows.first(where: {$0 is TimeModel}) as? TimeModel,
                    let second = $1.rows.first(where: {$0 is TimeModel}) as? TimeModel else {
                    return $0.rows.contains(where: { $0 is TimeModel })
                }
                return first.date > second.date
            }
//            contentAdapter.sectionContentUpdate = { section, context in
//                guard let content = context?["Title"] as? String else {
//                    return .nothing
//                }
//                section.set(header: content)
//                return .reload
//            }
            contentAdapter.sectionInitializer = { section, _, context in
                guard let content = context?["Title"] as? String else {
                    return
                }
                section.set(header: content)
            }
            contentAdapter.contentSectionizer = { content, sections in
                let calendar = Calendar.current
                let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: content.date)
                guard let start = calendar.date(from: components),
                    let end = calendar.date(byAdding: .day, value: 7, to: start) else {
                        return .new(nil)
                }
                let context = [Section.Keys.predicate: NSPredicate(block: { content, _ in
                    guard let content = content as? TimeModel else {
                        return false
                    }
                    return content.date > start && content.date < end
                }), "Title": "\(calendar.component(.month, from: start)) \(calendar.component(.year, from: end))"] as [String : Any]
                guard let sections = sections else {
                    return .new(context)
                }
                if let index = sections.firstIndex(where: { section in
                    return section.meetsPredicate(content: content) ?? false
                }) {
                    return .use(index)
                }
                return .new(context)
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
            let dateInterval: TimeInterval = 60 * 60 * 24 * 7
            contentAdapter.add(TimeModel(date: Date(timeIntervalSinceNow: Double.random(in: dateInterval..<dateInterval))))
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
    let type: Type = .dynamic
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
