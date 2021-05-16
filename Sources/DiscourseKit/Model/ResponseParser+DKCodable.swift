//
//  ResponseParser+DKCodable.swift
//  Networking
//
//  Created by Tanner on 4/27/19.
//

import Foundation
import Networking
import Jsum

public typealias DKCodingError = Jsum.Error

extension ResponseParser {
    static var decoder = Jsum().keyDecoding(strategy: .convertFromSnakeCase)
    
    func decodeResponse<T: DKCodable>(_: T.Type = T.self, _ keyPath: String? = nil) -> Result<T, DKCodingError> {
        if let error = self.error {
            return .failure(.other(error))
        }
        
        var json = try! JSONSerialization.jsonObject(with: self.data, options: [])
        
        // Extract the desired key path for decoding
        if let keyPath = keyPath {
            json = try! (json as! [String: Any]).jsum_value(for: keyPath)!
        }
        
        return Self.decoder.tryDecode(from: json)
    }
}
