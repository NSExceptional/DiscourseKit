//
//  User.swift
//  DiscourseKit
//
//  Created by Tanner on 3/31/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation

public class User: Thing {
    public static let missing = User(id: Int.max, name: "null", username: "[null]")
    
    public let id: Int
    public let name: String?
    public let username: String
    /// A string like `https://avatars.discourse.org/v2/letter/e/848f3c/{size}.png`
    public let avatar: String?

    public static var defaults: [String: Any] {
        return ["avatar": NSNull()]
    }

    private init(id: Int, name: String, username: String) {
        self.id = id
        self.name = name
        self.username = username
        self.avatar = ""
    }
}
