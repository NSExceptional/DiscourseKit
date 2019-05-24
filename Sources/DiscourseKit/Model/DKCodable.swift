//
//  DKCodable.swift
//  Model
//
//  Created by Tanner on 4/21/19.
//

import Foundation
import Extensions

enum Relation {
    case oneToOne(DKCodable.Type), oneToMany(DKCodable.Type)
}

protocol DKCodable: Codable {
    static var defaults: [String: Any] { get }
    static var types: [String: Relation] { get }
}

extension DKCodable {
    static var defaults: [String: Any] {
        return [:]
    }
    static var types: [String: Relation] {
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
        func applyDefaults(_ orig: [String: Any], _ type: DKCodable.Type) -> [String: Any] {
            return applyInnerDefaults(merge(orig, type.defaults), type.types)
        }
        // Applies defaults to one-to-many relationships within the object.
        // If `defaults` defines a key with the "_foreach" suffix,
        // we check to see if the key (without the suffix) in the original
        // object is an array. If it is, we load the defaults provided
        // by the type in the current defaults in the the "_foreach" key.
        func applyInnerDefaults(_ orig: [String: Any], _ relations: [String: Relation]) -> [String: Any] {
            var updated: [String: Any] = [:]
            // Loop over keys of the object until we find one which wishes to supply
            // defaults for an array of other objects. Track changes and replace them later.
            //
            // TODO: loop over defaults instead, more efficient
            for (key, value) in orig {
                if let relation = relations[key] {
                    switch relation {
                    case .oneToMany(let type):
                        if let objects = value as? [[String: Any]] {
                            // Apply defaults to each object in the list
                            let updatedObjects = objects.map { applyDefaults($0, type) }
                            updated[key] = updatedObjects
                        } else {
                            // TODO throw an error
                        }
                    case .oneToOne(let type):
                        if let object = value as? [String: Any] {
                            // Apply defaults to this one object
                            updated[key] = applyDefaults(object, type)
                        } else {
                            // TODO throw an error
                        }
                    }
                }
            }

            return updated.isEmpty ? orig : orig + updated
        }

        // Replace `null` entries with default values;
        // missing keys are replaced transparently here,
        // and inner defaults are applied at the end.
        func merge(_ orig: [String: Any], _ defaults: [String: Any]) -> [String: Any] {
            return orig.merging(defaults) { (curr, new) -> Any in
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
        }

//        let defaults = T.defaults
//        let relations = T.types
        let json = applyDefaults(json, T.self)
        
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

extension Array: DKCodable where Element: DKCodable { }
