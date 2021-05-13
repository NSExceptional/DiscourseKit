//
//  UntilOpenExistentials.swift
//  DiscourseKit
//
//  Created by Tanner Bennett on 5/13/21.
//

import Foundation
import Jsum

extension Listing.Order {
    public static func decode(from json: JSON) throws -> Listing.Order {
        // Make sure we're not coercing types, like 1 -> "1" or "foo" -> 0
        guard let string = json.unwrapped as? String else {
            throw Jsum.Error.couldNotDecode("Eum RawValue type mismatch")
        }
        return Self.init(rawValue: string /* json.toString */ )!
    }
}
