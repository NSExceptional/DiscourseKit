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
    private func latestComments(completion: @escaping DKResponseBlock<[Comment]>) {
        self.get(from: .comments) { parser in
            let response = parser.decodeResponse([Comment].self, "latest_posts")
            completion(response)
        }
    }
    
    var latestComments: AnyPublisher<[Comment], DKCodingError> {
        Future { promise in
            self.latestComments { promise($0) }
        }
        .eraseToAnyPublisher()
    }

    private func comment(with id: Int, completion: @escaping DKResponseBlock<Comment>) {
        self.get(from: .comment(for: id)) { parser in
            completion(parser.decodeResponse())
        }
    }
    
    func comment(with id: Int) -> AnyPublisher<Comment, DKCodingError> {
        Future { promise in
            self.comment(with: id) { promise($0) }
        }
        .eraseToAnyPublisher()
    }
}
