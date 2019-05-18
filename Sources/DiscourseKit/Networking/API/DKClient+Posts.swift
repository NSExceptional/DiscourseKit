//
//  DKClient+Posts.swift
//  DiscourseKit
//
//  Created by Tanner on 4/6/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Model

public extension DKClient {
    func latestPosts(completion: @escaping DKResponseBlock<[Post]>) {
        // TODO: parser.decodeResponse("key.path")
        struct LatestPosts: DKCodable {
            let latestPosts: [Post]
            static var defaults: [String : Any] {
                ["latest_posts_foreach": Post.self]
            }
        }
        
        self.get(from: .posts) { parser in
            let response: Result<LatestPosts,Error> = parser.decodeResponse()
            completion(response.map { $0.latestPosts })
        }
    }
    
    func post(with id: Int, completion: @escaping DKResponseBlock<Post>) {
        self.get(from: .post, pathParams: id.description) { parser in
            completion(parser.decodeResponse())
        }
    }
}
