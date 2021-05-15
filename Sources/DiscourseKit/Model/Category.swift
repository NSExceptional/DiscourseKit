//
//  Category.swift
//  DiscourseKit
//
//  Created by Tanner on 4/7/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation

public class Category: DKCodable {
    var id: Int
    var name: String
    var slug: String
    var color: String
    var position: Int
    var postCount: Int
    var topicCount: Int
    var hasChildren: Bool
    var subcategoryIds: [Int]
    var descriptionText: String
}
