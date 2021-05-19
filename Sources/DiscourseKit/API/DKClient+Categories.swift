//
//  DKClient+Categories.swift
//  Networking
//
//  Created by Tanner on 4/6/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation
import Jsum
import Combine

extension Array {
    static func +(lhs: [Element], rhs: Element) -> [Element] {
        var array = lhs
        array.append(rhs)
        return array
    }
}

public extension DKClient {
    func listCategories() -> DKResponse<[Category]> {
        self.get(from: .categories, node: "category_list.categories")
    }
    
    func getCategory(_ id: Int, checkCache: Bool = true) -> DKResponse<Category> {
        // Check the cache first...
        if checkCache, let cached = self.cachedCategory(with: id) {
            return .just(cached)
        }
        
        // Get the category, cache it, return it
        return self.get(from: .category(for: id), node: "category")
            .passthrough { self.cache(category: $0) }
    }
    
    private func cache(category cat: Category?) {
        guard let cat = cat else { return }
        self.encache(.category(for: cat.id), key: cat.id, value: cat)
    }
    
    private func cachedCategory(with id: Int) -> Category? {
        return self.check(cache: .category(for: id), key: id)
    }
}

extension Publisher where Output == [Post], Failure == DKError {
    public func fillInCategories(_ client: DKClient) -> DKResponse<[Post]> {
        let posts = self.flatMap { $0.publisher }
        return posts.flatMap {
            post in client.getCategory(post.categoryId)
        }
        .zip(posts).map { (category, post) -> Post in
            post.category = category.name
            return post
        }
        .collect()
        .eraseToAnyPublisher()
    }
}
