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
    // TODO: Convert this to an extension on Publisher, for more idiomatic Combine usage
    // extension Publisher where Output == [Post], Failure == DKError
    func fillInCategories<P: Publisher>(_ posts: P) -> DKResponse<[Post]>
    where P.Output == [Post], P.Failure == DKError {
        return posts.flatMap { posts in
            let categories = posts.publisher.flatMap { post in
                self.getCategory(post.categoryId)
            }

            let publishedPosts = posts.publisher.mapError { $0 as! DKError }
            return categories.zip(publishedPosts).map { category, post in
                post.category = category.name
                return post
            }
            .collect()
        }
        .eraseToAnyPublisher()
    }
    
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
