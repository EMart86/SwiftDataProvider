//
//  StringsTest.swift
//  SwiftDataProvider_Tests
//
//  Created by Martin Eberl on 16.12.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftDataProvider

class ObjcClass: NSObject {}

class SwiftClass {}

struct SwiftStruct {}

class StringsTest: XCTestCase {
    
    let testCases: [(String, Any)] = [("ObjcClass", ObjcClass.self),
                     ("ObjcClass", ObjcClass()),
                     ("SwiftClass", SwiftClass.self),
                     ("SwiftClass", SwiftClass()),
                     ("SwiftStruct", SwiftStruct.self),
                     ("SwiftStruct", SwiftStruct())]

    func testString() {
        for testCase in testCases {
            assert(String.string(from: testCase.1) == testCase.0)
        }
    }

}
