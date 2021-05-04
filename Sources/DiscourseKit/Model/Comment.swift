//
//  Post.swift
//  DiscourseKit
//
//  Created by Tanner on 4/7/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation

/// What we think of as "posts" and "comments" are called
/// "topics" and "posts/replies" by Discourse.
/// A Comment is a Post in Discourse jargon.
public class Comment: Created {
    public let id: Int
    public let createdAt: Date
    
    public let authorName: String?
    public let authorUsername: String
    public let authorAvatar: String?
    
    public let cooked: String?
    public let ignored: Bool
    public let likeCount: Int
    public let blurb: String?
    public let postNumber: Int
    public let topicId: Int
    
    public static var jsonKeyPathsByProperty: [String : String] = [
        "authorName": "name",
        "authorUsername": "username",
        "authorAvatar": "avatar_template",
    ]
}
