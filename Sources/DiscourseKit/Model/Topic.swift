//
//  Topic.swift
//  DiscourseKit
//
//  Created by Tanner on 4/7/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation

public class Topic: Created {
    public let id: Int
    public let createdAt: Date

    public let title: String
    public let fancyTitle: String
    public let slug: String
    public let categoryId: Int

    public let postsCount: Int
    public let replyCount: Int
    public let highestPostNumber: Int

    public let imageURL: String?
    public let lastPostedAt: Date
    public let bumped: Bool
    public let bumpedAt: Date
    public let pinned: Bool
    public let unpinned: Bool?
    public let visible: Bool
    public let closed: Bool
    public let archived: Bool
    public let bookmarked: Bool?
    public let liked: Bool?
    public let hasAcceptedAnswer: Bool
}
