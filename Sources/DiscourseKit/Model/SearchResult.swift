//
//  SearchResult.swift
//  Model
//
//  Created by Tanner on 4/7/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation

public class SearchResult: DKCodable {
    public let posts: [Comment]
    public let users: [User]
    public let topics: [Post]

    public var description: String {
        return "\(posts.count) posts, \(users.count) users, \(topics.count) topics"
    }

    static var types: [String: Relation] {
        return [
            "posts": .oneToMany(Comment.self),
            "users": .oneToMany(User.self),
            "topics": .oneToMany(Post.self)
        ]
    }
}
