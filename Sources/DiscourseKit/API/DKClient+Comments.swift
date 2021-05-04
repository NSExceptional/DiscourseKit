//
//  DKClient+Comments.swift
//  Networking
//
//  Created by Tanner on 4/6/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

public extension DKClient {
    /// Lists the latest comments across all posts.
    func latestComments(completion: @escaping DKResponseBlock<[Comment]>) {
        // TODO: parser.decodeResponse("key.path")
        struct LatestPosts: DKCodable {
            let latestPosts: [Comment]
        }

        self.get(from: .comments) { parser in
            let response: Result<LatestPosts,DKCodingError> = parser.decodeResponse()
            completion(response.map { $0.latestPosts })
        }
    }

    func comment(with id: Int, completion: @escaping DKResponseBlock<Comment>) {
        self.get(from: .comment, pathParams: id.description) { parser in
            completion(parser.decodeResponse())
        }
    }
}
