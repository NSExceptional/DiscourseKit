//
//  DKCodable.swift
//  Model
//
//  Created by Tanner on 4/21/19.
//

import Foundation
import Extensions

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
    
    static func decode<T: DKCodable>(from data: Data) throws -> T {
        // Deserialize JSON into dictionary, gather default key values
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        return try self.decode(from: json)
    }
    
    static func decode<T: DKCodable>(from json: [String: Any]) throws -> T {
        // Removes *_foreach keys where the prefix is another key
        func splitDefaultsFromInner(_ both: [String: Any]) -> (defaults: [String: Any], inner: [String: Any]) {
            let inner = both.filter { entry -> Bool in
                return entry.key.hasSuffix("_foreach")
            }
            let defaults = both.filter { !inner.keys.contains($0.key) }

            return (defaults, inner)
        }
        // Applies defaults to one-to-many relationships within the object.
        // If `defaults` defines a key with the "_foreach" suffix,
        // we check to see if the key (without the suffix) in the original
        // object is an array. If it is, we load the defaults provided
        // by the type in the current defaults in the the "_foreach" key.
        func applyInnerDefaults(_ orig: [String: Any], _ defaults: [String: Any]) -> [String: Any] {
            var updated: [String: Any] = [:]
            // Loop over keys of the object until we find one which wishes to supply
            // defaults for an array of other objcts. Track changes and replace them later.
            //
            // TODO: loop over defaults instead, more efficient
            for (key, value) in orig {
                if let type = defaults["\(key)_foreach"] as? DKCodable.Type,
                    let objects = value as? [[String: Any]] {
                    // Apply defaults to each object in the list
                    let updatedObjects = objects.map {
                        merge($0, type.defaults)
                    }
                    updated[key] = updatedObjects
                }
            }

            return updated.isEmpty ? orig : orig + updated
        }

        // Replace `null` entries with default values;
        // missing keys are replaced transparently here,
        // and inner defaults are applied at the end.
        func merge(_ orig: [String: Any], _ defaults: [String: Any]) -> [String: Any] {
            let (defaults, inner) = splitDefaultsFromInner(defaults)

            let merged = orig.merging(defaults) { (curr, new) -> Any in
                switch curr {
                case is [String: Any]:
                    let a = curr as! [String: Any]
                    let b = new as! [String: Any]
                    return merge(a, b)
                case is NSNull:
                    return new
                default:
                    return curr
                }
            }

            return applyInnerDefaults(merged, inner)
        }

        let defaults = T.defaults
        let json = merge(json, defaults)
        
        // Serialize data once again, create decoder
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            return JSONDecoder.DateDecodingStrategy.formatted(f)
        }()
        
        return try decoder.decode(T.self, from: data)
    }
}
