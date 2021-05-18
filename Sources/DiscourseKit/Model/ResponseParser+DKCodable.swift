//
//  ResponseParser+DKCodable.swift
//  Networking
//
//  Created by Tanner on 4/27/19.
//

import Foundation
import Networking
import Jsum

public enum DKError: Error {
    case networking(Error)
    case coding(Jsum.Error)
    
    var localizedDescription: String {
        switch self {
            case .networking(let e): return e.localizedDescription
            case .coding(let j): return j.localizedDescription
        }
    }
}

extension ResponseParser {
    static var decoder = Jsum().keyDecoding(strategy: .convertFromSnakeCase)
    
    func decodeResponse<T: DKCodable>(_: T.Type = T.self, _ keyPath: String? = nil) throws -> T {
        return try self.tryDecodeResponse(T.self, keyPath).get()
    }
    
    func tryDecodeResponse<T: DKCodable>(_: T.Type = T.self, _ keyPath: String? = nil) -> Result<T, DKError> {
        if let error = self.error {
            return .failure(.networking(error))
        }
        
        var json = try! JSONSerialization.jsonObject(with: self.data, options: [])
        
        // Extract the desired key path for decoding
        if let keyPath = keyPath {
            json = try! (json as! [String: Any]).jsum_value(for: keyPath)!
        }
        
        return Self.decoder.tryDecode(from: json).mapError { .coding($0) }
    }
}
