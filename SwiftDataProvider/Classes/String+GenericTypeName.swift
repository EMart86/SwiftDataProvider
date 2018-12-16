//
//  Any+String.swift
//  DynamicTableView
//
//  Created by Martin Eberl on 20.10.18.
//

import Foundation

extension String {
    internal static func string<T>(from type: T) -> String {
        let string = String(describing: type)
        if string.hasPrefix("<"), let range = string.range(of: ":") {
            return String(string[1..<range.lowerBound.encodedOffset])
        } else if let range = string.range(of: "(") {
            return String(string[0..<range.lowerBound.encodedOffset])
        } else if let range = string.range(of: ".", options: .backwards),
            let semicollonRange = string.range(of: ":", options: .backwards) {
            return String(string[range.upperBound..<semicollonRange.lowerBound])
        } else if let range = string.range(of: ".", options: .backwards) {
            return String(string[range.upperBound..<string.endIndex])
        } else {
            return string
        }
    }
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
