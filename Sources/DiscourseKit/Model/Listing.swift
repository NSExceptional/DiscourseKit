//
//  Listing.swift
//  Model
//
//  Created by Tanner on 4/6/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation
import Jsum

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

    public static var jsonKeyPathsByProperty: [String : String] = [
        // Keys are camel case because we're using .convertFromSnakeCase
        "nextPage": "more_topics_url", // TODO: switch back to camel case
        "order": "for_period",
        "posts": "topics",
        "canCreateTopic": "can_create_topic",
    ]

    public static var defaultsByProperty: [String : Any] = [
        // Listings from /latest.json don't actually include this key
        "order": Order.latest
    ]
}

extension Listing.Order: DKCodable, RawRepresentable {
    public static var defaultJSON: JSON = .string(Self.latest.rawValue)
    
    public init?(rawValue string: String) {
        if string == "latest" {
            self = .latest
        } else {
            self = .top(Period(rawValue: string)!)
        }
    }
    
    public init(from decoder: Decoder) throws {
        fatalError("Decodable not actually supported")
    }

    public var string: String {
        switch self {
            case .latest: return self.rawValue
            case .top(let p): return "top/" + p.rawValue
        }
    }

    public var rawValue: String {
        switch self {
            case .latest: return "latest"
            case .top(let p): return p.rawValue
        }
    }
}
