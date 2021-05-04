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
    func decodeResponse<T: DKCodable>() -> Result<T, DKCodingError> {
        if let error = self.error {
            return .failure(.other(error))
        }
        
        let json = try! JSONSerialization.jsonObject(with: self.data, options: [])
        return Jsum.tryDecode(from: json)
    }
}
