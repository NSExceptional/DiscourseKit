//
//  Person.swift
//  DiscourseKitTests
//
//  Created by Tanner on 4/27/19.
//

import Foundation
@testable import DiscourseKit

public struct Person: DKCodable, Equatable {
    
    static let bob = Person(name: "Bob", age: 50, married: true, kids: [sally], job: "Programmer")
    /// For testing purposes, Sally must be the same as the defaults
    static let sally = Person(name: "Sally", age: 5, married: false, kids: [], job: nil)
    
    var name: String
    var age: Int
    var married: Bool
    var kids: [Person]
    var job: String?
    
    public static var defaults: [String: Any] {
        return [
            "married": false,
            "kids": [] as JSONValue,
            "job": NSNull(), // NSNull for nil values
            "kids_foreach": Person.self
        ]
    }
}
