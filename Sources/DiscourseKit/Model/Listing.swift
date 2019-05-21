//
//  Listing.swift
//  Model
//
//  Created by Tanner Bennett on 5/21/19.
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
    public let order: Listing.Order
    public let users: [User]
    public internal(set) var posts: [Post]

    enum CodingKeys: String, CodingKey {
        case nextPage = "more_topics_url"
        case order = "for_period"
        case posts = "topics"
        case canCreateTopic, users
    }

    public static var defaults: [String : Any] {
        // Listings from /latest.json don't actually include this key
        return ["for_period": "latest"]
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
