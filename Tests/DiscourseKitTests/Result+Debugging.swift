//
//  Result+Debugging.swift
//  DiscourseKitTests
//
//  Created by Tanner on 5/16/19.
//

import Foundation

public extension Array where Element == CodingKey {
    var pathString: String {
        return "root" + self.map({ "["+$0.stringValue+"]" }).joined()
    }
}

extension DecodingError {
    var context: Context {
        switch self {
        case .typeMismatch(_, let c): return c
        case .valueNotFound(_, let c): return c
        case .keyNotFound(_, let c): return c
        case .dataCorrupted(let c): return c

        default:
            fatalError("Switching on unknown value")
        }
    }
}

public extension Result {
    var value: Success! {
        if case .success(let value) = self {
            return value
        }
        return nil
    }
    
    var string: String {
        switch self {

        case .success(let value):
            return "Success:\n\(value)"

        case .failure(let error):
            switch error {
            case is DecodingError:
                let context = (error as! DecodingError).context
                return context.debugDescription + "\n" + context.codingPath.pathString
            default:
                return error.localizedDescription
            }
        }
    }
}
