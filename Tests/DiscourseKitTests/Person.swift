//
//  Person.swift
//  DiscourseKitTests
//
//  Created by Tanner on 4/27/19.
//

import Foundation
@testable import DiscourseKit

struct Person: DKCodable, Equatable {
    
    static let bob = Person(name: "Bob", age: 50, married: true, kids: [sally], job: "Programmer")
    static let sally = Person(name: "Sally", age: 5, married: false, kids: [], job: nil)
    
    var name: String
    var age: Int
    var married: Bool
    var kids: [Person]
    var job: String?
    
    static var defaults: [String: Any] {
        return [
            "married": false,
            "kids": [],
            "job": NSNull(),
        ]
    }
}
