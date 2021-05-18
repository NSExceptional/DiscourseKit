//
//  DKClient+Search.swift
//  DiscourseKit
//
//  Created by Tanner on 4/7/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Combine

public extension DKClient {
    func search(term: String, includeBlurbs blurbs: Bool = false) -> DKResponse<SearchResult> {
        self.get(["q": term, "include_blurbs": blurbs], from: .search)
    }
}
