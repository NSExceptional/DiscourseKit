//
//  XCTestExtensions.swift
//  Extensions
//
//  Created by Tanner on 5/17/19.
//

import XCTest
import DiscourseKit

extension XCTestExpectation {
    func success<T>(_ result: Result<T, DKError>) {
        XCTAssert(result.succeeded)
        self.fulfill()
    }
}
