//
//  DKClient+Categories.swift
//  Networking
//
//  Created by Tanner on 4/6/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation

public extension DKClient {
    func listCategories(completion: @escaping DKResponseBlock<[Category]>) {
        self.get(from: .categories) { parser in
            let response = parser.decodeResponse([Category].self, "category_list.categories")
            completion(response)
        }
    }
}
