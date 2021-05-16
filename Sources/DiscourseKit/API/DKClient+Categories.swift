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
    private func fillInCategories(_ posts: [Post], fetchChildren: Bool = true, completion: @escaping DKResponseBlock<Void>) {
        precondition(!posts.isEmpty)
        
        // We're going to fetch each category one by one,
        // so we need to keep track of how many there are and how
        // many we've fetched so far. Abort all progress on an error.
        let total = posts.count
        var completeCount = 0
        var failed = false
        
        for post in posts {            
            // Get the category
            self.getCategory(post.categoryId) { result in
                completeCount += 1
                
                // If we haven't encountered an error already...
                if !failed {
                    switch result {
                        // Assign the category name to the post
                        case .success(let cat):
                            post.category = cat.name
                            if completeCount == total {
                                completion(.success(()))
                            }
                            
                        // Return an error and abort the other calls
                        case .failure(let error):
                            failed = true
                            completion(.failure(error))
                    }
                }
            }
        }
    }
    
    func fillInCategories(for posts: [Post], fetchChildren: Bool = true) -> AnyPublisher<Void, DKCodingError> {
        Future { promise in
            self.fillInCategories(posts, fetchChildren: fetchChildren) { promise($0) }
        }
        .eraseToAnyPublisher()
    }
        
    private func listCategories(completion: @escaping DKResponseBlock<[Category]>) {
        self.get(from: .categories) { parser in
            completion(parser.decodeResponse([Category].self, "category_list.categories"))
        }
    }
    
    var categories: AnyPublisher<[Category], DKCodingError> {
        Future { promise in
            self.listCategories { promise($0) }
        }
        .eraseToAnyPublisher()
    }
    
    private func getCategory(_ id: Int, checkCache: Bool = true, completion: @escaping DKResponseBlock<Category>) {
        // Check the cache first...
        if checkCache, let cached = self.cachedCategory(with: id) {
            completion(.success(cached))
        }
        
        // Get the category, cache it, return it
        self.get(from: .category(for: id)) { parser in
            let result = parser.decodeResponse(Category.self, "category")
            self.cache(category: try? result.get())
            completion(result)
        }
    }
    
    func category(for id: Int, checkCache: Bool = true) -> AnyPublisher<Category, DKCodingError> {
        Future { promise in
            self.getCategory(id, checkCache: checkCache) { promise($0) }
        }
        .eraseToAnyPublisher()
    }
    
    private func cache(category cat: Category?) {
        guard let cat = cat else { return }
        self.encache(.category(for: cat.id), key: cat.id, value: cat)
    }
    
    private func cachedCategory(with id: Int) -> Category? {
        return self.check(cache: .category(for: id), key: id)
    }
}
