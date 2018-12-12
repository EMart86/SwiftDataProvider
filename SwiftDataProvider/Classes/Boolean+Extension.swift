//
//  Boolean+Extension.swift
//  Pods-LoginExample
//
//  Created by Martin Eberl on 09.12.18.
//

import Foundation

extension Bool {
    var isTrue: Bool {
        return self == true
    }
    
    var isFalse: Bool {
        return self == false
    }
}

extension Optional where Wrapped == Bool {
    var isTrue: Bool {
        guard let strong = self else {
            return false
        }
        return strong
    }
    
    var isFalse: Bool {
        guard let strong = self else {
            return true
        }
        return strong
    }
}
