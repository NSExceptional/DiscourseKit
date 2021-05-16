//
//  Tests.swift
//  Tests
//
//  Created by Tanner on 4/5/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import XCTest
import Combine
import CombineExpectations
@testable import DiscourseKit

class Tests: XCTestCase {
    let api = DKClient("https://forums.swift.org")

    func testSearch() {
        let search = api.search(term: "codable")
        let recorder = search.record()
        
        XCTAssertNoThrow(try wait(
            for: recorder.elements,
            timeout: 100,
            description: "search"
        ))
    }

    func testFeedLatest() throws {
        let feed = api.feed()
        let recorder = feed.record()
        let listing = try wait(
            for: recorder.elements,
            timeout: 100,
            description: "feed latest"
        ).first!
        
        XCTAssertEqual(listing.order, .latest)
    }

    func testFeedTop() throws {
        let feed = api.feed(.top(.month))
        let recorder = feed.record()
        let listing = try wait(
            for: recorder.elements,
            timeout: 100,
            description: "feed top of the month"
        ).first!
        
        XCTAssertEqual(listing.order, .top(.month))
    }

    func testGetAllCategories() throws {
        let recorder = api.categories.record()
        let categories = try wait(
            for: recorder.elements,
            timeout: 100,
            description: "get all categories"
        ).first!
        
        XCTAssert(categories.count > 0)
    }

    func testComments() {
        let comments = api.latestComments
        let recorder = comments.record()
        
        XCTAssertNoThrow(try wait(
            for: recorder.elements,
            timeout: 100,
            description: "comments"
        ))
    }

    func testGetComment() {
        let comment = api.comment(with: 129212)
        let recorder = comment.record()
        
        XCTAssertNoThrow(try wait(
            for: recorder.elements,
            timeout: 100,
            description: "get comment"
        ))
    }

//    func testLogin() {
//        let login = api.login(<#T##username: String##String#>, <#T##password: String##String#>)
//        let recorder = login.record()
//
//        XCTAssertNoThrow(try wait(
//            for: recorder.elements,
//            timeout: 0,
//            description: "login"
//        ))
//    }
}
