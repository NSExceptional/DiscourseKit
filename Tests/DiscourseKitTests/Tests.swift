//
//  Tests.swift
//  Tests
//
//  Created by Tanner on 4/5/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import XCTest
@testable import DiscourseKit

class Tests: XCTestCase {
    
    let api = DKClient("https://forums.swift.org")
    
    func asyncTest(for expectationDesc: String, block: (XCTestExpectation) -> Void) {
        let expectation = self.expectation(description: expectationDesc)
        block(expectation)
        self.wait(for: [expectation], timeout: 10)
    }

//    func testLogin() {
//        self.asyncTest(for: "login") { (exp) in
//            api.login(<#username#>, <#password#>) { (error) in
//                XCTAssertNil(error)
//                exp.fulfill()
//            }
//        }
//    }
}
