//
//  ResponseParser+DKCodable.swift
//  Networking
//
//  Created by Tanner on 4/27/19.
//

import Foundation
import Networking
public typealias DKCodingError = Swift.Error

extension ResponseParser {
    func decodeResponse<T: DKCodable>() -> Result<T, DKCodingError> {
        if let error = self.error {
            return .failure(error)
        }
        
        return T.tryDecode(from: self.data)
    }
}
