//
//  Boolean+Extension.swift
//  Pods-LoginExample
//
//  Created by Martin Eberl on 09.12.18.
//

import Foundation

extension Bool {
    public var isTrue: Bool {
        return self == true
    }
    
    public var isFalse: Bool {
        return self == false
    }
}

extension Optional where Wrapped == Bool {
    public var isTrue: Bool {
        guard let strong = self else {
            return false
        }
        return strong
    }
    
    public var isFalse: Bool {
        guard let strong = self else {
            return true
        }
        return strong
    }
}
