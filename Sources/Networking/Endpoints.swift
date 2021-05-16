//
//  Endpoints.swift
//  DiscourseKit
//
//  Created by Tanner on 3/31/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation

/// Discourse API endpoints.
public struct Endpoint: RawRepresentable, Hashable {
    public init(rawValue: String) { self.rawValue = rawValue }
    public let rawValue: String
    
    public static let preAuth: Self = .init(rawValue: "/session/csrf")
    public static let login: Self = .init(rawValue: "/session")
    public static let search: Self = .init(rawValue: "/search")
    
    public static let comments: Self = .init(rawValue: "/posts.json")
    public static func comment(for id: Int) -> Self {
        .init(rawValue: "/posts/\(id).json")
    }
    
    public static func feed(for id: String) -> Self {
        .init(rawValue: "/\(id).json")
    }
    
    public static let categories: Self = .init(rawValue: "/categories.json")
    public static func category(for id: Int) -> Self {
        .init(rawValue: "/c/\(id)/show.json")
    }
}
