//
//  Dictionary+Networking.swift
//  DiscourseKit
//
//  Created by Tanner on 4/2/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation


public extension Dictionary where Key == String, Value == JSONValue {
    var jsonString: String {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else {
            return "{}"
        }
        
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    var asQueryItems: [URLQueryItem] {
        return self.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
    }
}

/// For joining dictionaries; contents of `right` take preceedence over `left`
public func + <K,V> (left: Dictionary<K,V>, right: Dictionary<K,V>?) -> Dictionary<K,V> {
    guard let right = right else { return left }
    return left.merging(right) { (_, new) -> V in
        return new
    }
}

/// For joining dictionaries; contents of `right` take preceedence over `left`
public func += <K,V> (left: inout Dictionary<K,V>, right: Dictionary<K,V>?) {
    guard let right = right else { return }
    left.merge(right) { (_, new) -> V in
        return new
    }
}
