//
//  DKClient+Comments.swift
//  Networking
//
//  Created by Tanner on 4/6/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Combine

public extension DKClient {
    
    /// Lists the latest comments across all posts.
    func latestComments() -> DKResponse<[Comment]> {
        self.get(from: .comments, node: "latest_posts")
    }

    func comment(with id: Int) -> DKResponse<Comment> {
        self.get(from: .comment(for: id))
    }
}
