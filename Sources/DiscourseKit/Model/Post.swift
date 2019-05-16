//
//  Post.swift
//  DiscourseKit
//
//  Created by Tanner on 4/7/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation

public class Post: Created {
    public let id: Int
    public let createdAt: Date
    
    public private(set) var authorName: String? = nil
    public let authorUsername: String
    public let authorAvatar: String?
    
    public private(set) var cooked: String? = nil
    public let ignored: Bool
    public let likeCount: Int
    public let blurb: String
    public let postNumber: Int
    public let topicId: Int

    public static var defaults: [String: Any] {
        return [
            "avatar_template": NSNull(),
            "ignored": false
        ]
    }
    
    enum CodingKeys: String, CodingKey {
        case authorName = "name"
        case authorUsername = "username"
        case authorAvatar = "avatar_template"
        case id, createdAt, cooked, ignored, likeCount, blurb, postNumber, topicId
    }
}
