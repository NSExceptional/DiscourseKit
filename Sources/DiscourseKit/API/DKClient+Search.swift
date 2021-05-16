//
//  DKClient+Search.swift
//  DiscourseKit
//
//  Created by Tanner on 4/7/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Combine

public extension DKClient {
    func search(term: String, includeBlurbs blurbs: Bool = false, completion: @escaping DKResponseBlock<SearchResult>) {
        self.get(["q": term, "include_blurbs": blurbs], from: .search) { parser in
            completion(parser.decodeResponse())
        }
    }
    
    func search(term: String, includeBlurbs blurbs: Bool = false) -> AnyPublisher<SearchResult, DKCodingError> {
        Future { promise in
            self.search(term: term, includeBlurbs: blurbs) { promise($0) }
        }
        .eraseToAnyPublisher()
    }
}
