//
//  DKClient+Feed.swift
//  Networking
//
//  Created by Tanner on 4/6/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Extensions
import Combine

public extension DKClient {
    func feed(_ sort: Listing.Order = .latest) -> DKResponse<Listing> {
        struct FeedResponse: DKCodable {
            let users: [User]
            let topicList: Listing
        }

        return self.get(from: .feed(for: sort.path)).map { (feed: FeedResponse) in
            // Take `users` and use it to populate the `author`
            // and `participants` of each post in the Listing
            for post in feed.topicList.posts {
                // Grab the OP user
                if let op = post.posters.where(\.isOP),
                    let author = feed.users.where(\.id, is: op.userID) {
                    post.author = author
                } else {
                    post.author = User.missing
                }

                // Map Participants to Users
                post.participants = post.posters.compactMap {
                    feed.users.where(\.id, is: $0.userID)
                }
            }

            return feed.topicList
        }
        .eraseToAnyPublisher()
    }
}
