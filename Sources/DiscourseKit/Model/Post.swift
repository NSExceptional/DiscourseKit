//
//  Topic.swift
//  DiscourseKit
//
//  Created by Tanner on 4/7/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation
import Extensions

/// What we think of as "posts" and "comments" are called
/// "topics" and "posts/replies" by Discourse.
/// A Post is a Topic in Discourse jargon.
public class Post: Created {
    
    public let id: Int
    public let createdAt: Date

    public let title: String
    public let fancyTitle: String
    public let slug: String
    public let categoryId: Int

    public internal(set) var author: User = .missing
    public internal(set) var participants: [User] = []

    public let postsCount: Int
    public let replyCount: Int
    public let highestPostNumber: Int

    public let imageURL: String?
    public let lastPostedAt: Date
    public let bumped: Bool
    public let bumpedAt: Date
    public let pinned: Bool
    public let unpinned: Bool
    public let visible: Bool
    public let closed: Bool
    public let archived: Bool
    public let bookmarked: Bool
    public let liked: Bool
    public let hasAcceptedAnswer: Bool

    /// The API returns thread participants in `posters`
    /// but we want our API to expose entire users via `participants`.
    /// This property is used to populate `participants` and `author`.
    internal let posters: [Participant]
    internal class Participant: Codable {
        let description: String
        let userId: Int
        var isOP: Bool {
            return description == "Original Poster"
        }
    }

    // We wish to exclude `author` and `participants` from being decoded
    public enum CodingKeys: String, CodingKey {
        case id, createdAt, title, fancyTitle, slug
        case categoryId, postsCount, replyCount, posters
        case highestPostNumber, imageURL, lastPostedAt
        case bumped, bumpedAt, pinned, unpinned, visible
        case closed, archived, bookmarked, liked, hasAcceptedAnswer
    }

    public static var defaults: [String: Any] {
        return self.thing_defaults + [
//            "imageURL": nil,
            "unpinned": false,
            "bookmarked": false,
            "liked": false,
        ]
    }
}
