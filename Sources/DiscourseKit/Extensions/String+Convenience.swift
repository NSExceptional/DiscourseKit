//
//  String+Convenience.swift
//  DiscourseKit
//
//  Created by Tanner on 3/31/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation

prefix operator ~
prefix func ~(int: UInt8) -> Character {
    return Character(UnicodeScalar(int))
}
prefix func ~(c: Character) -> UnicodeScalar {
    return UnicodeScalar(c.asciiValue!)
}
prefix func ~(c: Character) -> CVarArg {
    return CChar(c.asciiValue!)
}

func ~=(lhs: CharacterSet, rhs: Character) -> Bool {
    return lhs.contains(~rhs)
}

public extension String {
    var utf8Data: Data {
        return self.data(using: .utf8)!
    }
    
    var urlEncoded: String {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "=@&.-_~ ")
        allowed.subtract(.alphanumerics)
        
        let encoded = self.addingPercentEncoding(withAllowedCharacters: allowed)!
        return encoded.replacingOccurrences(of: " ", with: "+")
        
        // I'm very annoyed that String doesn't provide mutating
        // versions of replacingOccurrences() and friends. The code
        // below may be more efficient since it doesn't do lots of copying.
        // I don't want to delete it just yet.
//        var encoded = self
//        let source  = self.utf8Data
//        let srcLen  = source.count
//        
//        for byte in source {
//            let c: Character = ~byte
//            switch c {
//            case " ":
//                encoded.append("+")
//            case ".", "-", "_", "~", "a"..."z", "A"..."Z", "0"..."9":
//                encoded.append(c)
//            default:
//                encoded.append(format: "%%%02X", ~c)
//            }
//        }
//        
//        return encoded
    }
    
    func url(with queries: [String: JSONValue]) -> URL {
        guard !queries.isEmpty else {
            return URL(string: self)!
        }
        
        var url = self
        if url.hasSuffix("/") {
            url.remove(at: url.endIndex)
        }
        
        url.append("?" + queries.queryString)
        return URL(string: url)!
    }
}

extension NSMutableString {
    func replace(_ str: String, with other: String) {
        self.replaceOccurrences(of: " ", with: "+", options: [], range: NSMakeRange(0, self.length))
    }
}

extension String {
    mutating func append(format: String,  _ args: CVarArg...) {
        self.append(String(format: format, args))
    }
} 
