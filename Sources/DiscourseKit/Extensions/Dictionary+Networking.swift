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
    
    var queryString: String {
        return self.queryString(urlEscape: true)
    }
    
    var unescapedQueryString: String {
        return self.queryString(urlEscape: false)
    }
    
    func queryString(urlEscape: Bool) -> String {
        guard !self.isEmpty else {
            return ""
        }
        
        var q = ""
        
        for (key, value) in self {
            if var value = value as? String, !value.isEmpty {
                if urlEscape {
                    value = value.urlEncoded
                } else {
                    value = value.replacingOccurrences(of: " ", with: "+")
                }
                
                q.append(format: "%@=%@&", key.urlEncoded, value)
            } else {
                q.append(format: "%@=%@&", key.urlEncoded, value)
            }
        }
        
        q.remove(at: q.endIndex)
        return q
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
