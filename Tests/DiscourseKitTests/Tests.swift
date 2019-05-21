//
//  Tests.swift
//  Tests
//
//  Created by Tanner on 4/5/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import XCTest
@testable import DiscourseKit

extension Result {
    var isSuccess: Bool {
        switch self {
        case .success(_):
            return true
        default:
            return false
        }
    }
}

class Tests: XCTestCase {
    
    let api = DKClient("https://forums.swift.org")
    
    func asyncTest(for expectationDesc: String, block: (XCTestExpectation) -> Void) {
        let expectation = self.expectation(description: expectationDesc)
        block(expectation)
        self.wait(for: [expectation], timeout: 10)
    }

    func testSearch() {
        self.asyncTest(for: "search") { (exp) in
            api.search(term: "codable", completion: { exp.success($0) })
        }
    }
    
    func testComments() {
        self.asyncTest(for: "comments") { (exp) in
            api.latestComments(completion: { exp.success($0) })
        }
    }
    
    func testGetComment() {
        self.asyncTest(for: "get comment") { (exp) in
            api.comment(with: 129212, completion: { exp.success($0) })
        }
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
