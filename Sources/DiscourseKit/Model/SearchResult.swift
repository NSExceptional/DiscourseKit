//
//  SearchResult.swift
//  Model
//
//  Created by Tanner on 4/7/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation

public class SearchResult: DKCodable {
    let posts: [Post]
    let users: [User]
    let topics: [Topic]
}
