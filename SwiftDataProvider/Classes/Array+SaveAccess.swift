//
//  Array+SaveAccess.swift
//  Pods-LoginExample
//
//  Created by Martin Eberl on 30.12.18.
//

import Foundation

extension Array {
    public subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
