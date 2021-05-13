//
//  TestDKCodable.swift
//  DiscourseKitTests
//
//  Created by Tanner on 4/27/19.
//

import Foundation
import XCTest
import Jsum
@testable import DiscourseKit

typealias JSON = [String: Any]

class TestDKCodable: XCTestCase {
    let kid = Person.sally
    var mock = Person.bob

    let kidJSON: JSON = [
        "name": "Sally",
        "age": 5,
    ]
    
    lazy var complete: JSON = [
        "name": mock.name,
        "age": mock.age,
        "married": mock.married,
        "kids": [self.kidJSON],
        "job": mock.job!,
    ]
    lazy var incompleteWithDefaults: JSON = [
        "name": mock.name,
        "age": mock.age,
    ]
    lazy var NSNullsWithDefaults: JSON = [
        "name": mock.name,
        "age": mock.age,
        "married": NSNull(),
        "kids": NSNull(),
        "job": NSNull(),
    ]
    lazy var incomplete: JSON = [
        "married": mock.married,
        "kids": [self.kidJSON],
        "job": mock.job!,
    ]
    lazy var NSNulls: JSON = [
        "name": NSNull(),
        "age": NSNull(),
        "married": true,
        "kids": [],
        "job": mock.job!,
    ]
    lazy var arrays: JSON = [
        "name": mock.name,
        "age": mock.age,
        "married": mock.married,
        "kids": [self.kidJSON], //self.kidJSON, self.kidJSON],
        "job": mock.job!,
    ]
    
    override func setUp() {
        self.mock = Person.bob
    }
    
    func setMockToPersonDefaults() {
        mock.married = false
        mock.kids = []
        mock.job = nil
    }
    
    func decode<T: DKCodable>(_ json: JSON) throws -> T {
        return try Jsum.decode(from: json)
    }
    
    func checkSame(_ a: Person, _ b: Person) {
        XCTAssertEqual(a.name, b.name)
        XCTAssertEqual(a.age, b.age)
        XCTAssertEqual(a.married, b.married)
        XCTAssert(a.kids.elementsEqual(b.kids))
    }
    
    func testComplete() throws {
        let p: Person = try self.decode(self.complete)
        self.checkSame(p, mock)
    }
    
    func testIncompleteWithDefaults() throws {
        self.setMockToPersonDefaults()
        
        let p: Person = try self.decode(self.incompleteWithDefaults)
        self.checkSame(p, mock)
    }
    
    func testNSNullslWithDefaults() throws {
        self.setMockToPersonDefaults()

        let p: Person = try self.decode(self.NSNullsWithDefaults)
        self.checkSame(p, mock)
    }
    
    func testIncompleteFillInDefaults() throws {
        let _: Person = try self.decode([:])
    }
    
    func testNSNulls() throws {
        let result = Jsum()
            .failOnNullNonOptionals()
            .tryDecode(Person.self, from: self.NSNulls)
        XCTAssert(result.failed)
    }

    func testArray() throws {
        mock.kids = [Person.sally]

        let p: Person = try self.decode(self.arrays)
        self.checkSame(p, mock)
    }
}
