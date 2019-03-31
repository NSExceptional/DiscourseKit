//
//  Thing.swift
//  DiscourseKit
//
//  Created by Tanner on 4/7/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation

public protocol Thing: DKCodable {
    var id: Int { get }
}

public extension Thing {
    static var unavaliableID: Int {
        return Int.max
    }
    
    static var defaults: [String: Any] {
        return ["id": -1]
    }
}
