//
//  Endpoints.swift
//  DiscourseKit
//
//  Created by Tanner on 3/31/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation

/// Discourse API endpoints
public struct Endpoint: Hashable, RawRepresentable, ExpressibleByStringLiteral {
    public let rawValue: String
    
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(stringLiteral value: String) { self.init(rawValue: value) }

    public static let preAuth: Self = "/session/csrf"
    public static let login: Self = "/session"
    public static let search: Self = "/search"
    
    public static let comments: Self = "/posts.json"
    public static func comment(for id: Int) -> Self {
        .init(rawValue: "/posts/\(id).json")
    }
    
    public static func feed(for id: String) -> Self {
        .init(rawValue: "/\(id).json")
    }
    
    public static let categories: Self = "/categories.json"
    public static func category(for id: Int) -> Self {
        .init(rawValue: "/c/\(id)/show.json")
    }
}
