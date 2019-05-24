//
//  ResponseParser+DKCodable.swift
//  Networking
//
//  Created by Tanner on 4/27/19.
//

import Networking

extension ResponseParser {
    func decodeResponse<T: DKCodable>() -> Result<T, Error> {
        if let error = self.error {
            return .failure(error)
        }
        
        return T.tryDecode(from: self.data)
    }
}
