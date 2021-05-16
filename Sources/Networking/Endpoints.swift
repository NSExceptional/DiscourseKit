//
//  Endpoints.swift
//  DiscourseKit
//
//  Created by Tanner on 3/31/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation

/// Discourse API endpoints.
///
/// Each endpoint is a string that may or may not have
/// path parameters. If an endpoint *does* have path
/// parameters, you must call `make(_:)` with the
/// parameters to generate the fully fully-formed endpoint.
public enum Endpoint: String {
    
    case preAuth = "/session/csrf"
    case login = "/session"
    case search = "/search"
    
    case comments = "/posts.json"
    case comment = "/posts/%@.json"

    case feed = "/%@.json"
    
    case categories = "/categories.json"
    case category = "/c/%@/show.json"
    
    /// Takes a list of path parameters and
    /// builds a fully-formed endpoint.
    ///
    /// Ideally, we would be able to dynamically get a list
    /// of an enum case's associated values and build the
    /// string by hand, so that it remains totally type-safe
    /// and free of case-by-case boilerplate. Perhaps in the future.
    public func make(_ args: [String]) -> String {
        if args.isEmpty {
            return self.rawValue
        } else {
            return String(format: self.rawValue, arguments: args)
        }
    }
}
