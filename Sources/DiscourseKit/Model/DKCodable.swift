//
//  DKCodable.swift
//  Model
//
//  Created by Tanner on 4/21/19.
//

import Foundation

public protocol DKCodable: Codable {
    static var defaults: [String: Any] { get }
}

public extension DKCodable {
    static var defaults: [String: Any] {
        return [:]
    }
    
    static func tryDecode(from data: Data) -> Result<Self, Error> {
        do {
            return .success(try self.decode(from: data))
        } catch {
            return .failure(error)
        }
    }
    
    static func tryDecode(from json: [String: Any]) -> Result<Self, Error> {
        do {
            return .success(try self.decode(from: json))
        } catch {
            return .failure(error)
        }
    }
    
    static func decode(from data: Data) throws -> Self {
        // Deserialize JSON into dictionary, gather default key values
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        return try self.decode(from: json)
    }
    
    static func decode(from json: [String: Any]) throws -> Self {
        var json = json
        let defaults = Self.defaults
        // Replace `null` entries with default values;
        // missing keys are replaced transparently here
        json.merge(defaults) { (curr, new) -> Any in
            return (curr is NSNull) ? new : curr
        }
        
        // Serialize data once again, create decoder
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(self, from: data)
    }
}
