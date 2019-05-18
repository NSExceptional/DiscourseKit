//
//  XCTestExtensions.swift
//  Extensions
//
//  Created by Tanner on 5/17/19.
//

import XCTest

extension XCTestExpectation {
    func success<T>(_ result: Result<T, Error>) {
        XCTAssert(result.isSuccess)
        self.fulfill()
    }
}
