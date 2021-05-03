//
//  Listing.swift
//  Model
//
//  Created by Tanner on 4/6/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation

public class Listing: DKCodable {
    public enum Order {
        public enum Period: String, Codable {
            case allTime = "all"
            case year = "yearly"
            case quarter = "quarterly"
            case month = "monthly"
            case day = "daily"
        }

        case latest
        case top(Period)
    }

    public let canCreateTopic: Bool
    public let nextPage: String
    public let order: Order
    public internal(set) var posts: [Post]

    enum CodingKeys: String, CodingKey {
        // Keys are camel case because we're using .convertFromSnakeCase
        case nextPage = "moreTopicsUrl"
        case order = "forPeriod"
        case posts = "topics"
        case canCreateTopic
    }

    public static var defaults: [String : Any] {
        // Listings from /latest.json don't actually include this key
        return ["for_period": "latest"]
    }
    public static var types: [String: Relation] {
        return ["topics": .oneToMany(Post.self)]
    }
}

extension Listing.Order: Codable {
    enum CodingKeys: CodingKey {
        case latest
    }

    public var string: String {
        switch self {
        case .latest: return "latest"
        case .top(let p): return "top/" + p.rawValue
        }
    }

    private var rawValue: String {
        switch self {
        case .latest: return "latest"
        case .top(let p): return p.rawValue
        }
    }

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        if value == "latest" {
            self = .latest
        } else {
            self = .top(try Period(from: decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}
