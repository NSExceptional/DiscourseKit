//
//  DKClient+Comments.swift
//  Networking
//
//  Created by Tanner Bennett on 5/21/19.
//

public extension DKClient {
    /// Lists the latest comments across all posts.
    func latestComments(completion: @escaping DKResponseBlock<[Comment]>) {
        // TODO: parser.decodeResponse("key.path")
        struct LatestPosts: DKCodable {
            let latestPosts: [Comment]
            static var defaults: [String : Any] {
                return ["latest_posts_foreach": Comment.self]
            }
        }

        self.get(from: .comments) { parser in
            let response: Result<LatestPosts,Error> = parser.decodeResponse()
            completion(response.map { $0.latestPosts })
        }
    }

    func comment(with id: Int, completion: @escaping DKResponseBlock<Comment>) {
        self.get(from: .comment, pathParams: id.description) { parser in
            completion(parser.decodeResponse())
        }
    }
}
