//
//  DKClient+Feed.swift
//  Networking
//
//  Created by Tanner Bennett on 5/21/19.
//

import Model

public extension DKClient {
    func feed(_ sort: Listing.Order = .latest, completion: @escaping DKResponseBlock<Listing>) {
        struct FeedResponse: DKCodable {
            let users: [User]
            let topicList: Listing
            static var defaults: [String : Any] {
                return ["users_foreach": User.self, "topic_list_foreach": Post.self]
            }
        }

        self.get(from: .feed, pathParams: sort.string) { parser in
            let response: Result<FeedResponse,Error> = parser.decodeResponse()
            completion(response.map {
                for post in $0.topicList.posts {
                    for participant in post.posters {
                        // TODO put API and Model in the same target
                        // Separate API from Networking
                    }
                }
            })
        }
    }
}
