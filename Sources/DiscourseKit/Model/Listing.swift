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
    public enum Order: Equatable {
        public enum Period: String, DKCodable, Equatable {
            case allTime = "all"
            case year = "yearly"
            case quarter = "quarterly"
            case month = "monthly"
            case day = "daily"
            
            public static var all: [Period] = [
                .allTime, .year, .quarter, .month, .day
            ]
            
            public var description: String {
                switch self {
                    case .allTime: return "all time"
                    case .year: return "this year"
                    case .quarter: return "last quarter"
                    case .month: return "this month"
                    case .day: return "today"
                }
            }
        }

        case new
        case latest
        case top(Period)
        
        public static var all: [Order] = Period.all.map { .top($0) } + [.latest, .new]
        
        public var description: String {
            switch self {
                case .new: return "New"
                case .latest: return "Hot"
                case .top(let period): return "Top of " + period.description 
            }
        }
    }

    public let canCreateTopic: Bool
    public let nextPage: String
    public let order: Order
    public internal(set) var posts: [Post]

    public static var jsonKeyPathsByProperty: [String : String] = [
        "nextPage": "more_topics_url",
        "order": "for_period",
        "posts": "topics",
    ]

    public static var defaultsByProperty: [String : Any] = [
        // Listings from /latest.json don't actually include this key
        "order": Order.latest
    ]
}

extension Listing.Order: DKCodable, RawRepresentable {
    public static var defaultJSON: JSON = .string(Self.latest.rawValue)
    
    public init?(rawValue string: String) {
        switch string {
            case "latest": self = .latest
            case "new": self = .new
            default: self = .top(Period(rawValue: string)!)
        }
    }
    
    public init(from decoder: Decoder) throws {
        fatalError("Decodable not actually supported")
    }

    public var path: String {
        switch self {
            case .top(let p): return "top/" + p.rawValue
            default: return self.rawValue
        }
    }

    public var rawValue: String {
        switch self {
            case .new: return "new"
            case .latest: return "latest"
            case .top(let p): return p.rawValue
        }
    }
}
