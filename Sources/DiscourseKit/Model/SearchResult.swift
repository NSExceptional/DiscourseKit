//
//  SearchResult.swift
//  Model
//
//  Created by Tanner on 4/7/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation

public class SearchResult: DKCodable {
    public let posts: [Post]
    public let users: [User]
    public let topics: [Topic]

    public var description: String {
        return "\(posts.count) posts, \(users.count) users, \(topics.count) topics"
    }

    public static var defaults: [String: Any] {
        return [
            "posts_foreach": Post.self,
            "users_foreach": User.self,
            "topics_foreach": Topic.self
        ]
    }
}
