//
//  EnumEqualities.swift
//  DiscourseKitTests
//
//  Created by Tanner Bennett on 5/23/19.
//

import DiscourseKit

extension Listing.Order: Equatable {
    public static func ==(lhs: Listing.Order, rhs: Listing.Order) -> Bool {
        switch (lhs, rhs) {
        case (.latest, .latest): return true
        case (.top(let p1), .top(let p2)): return p1 == p2
        default: return false
        }
    }
}
