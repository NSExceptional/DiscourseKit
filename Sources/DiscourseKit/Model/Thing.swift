//
//  Thing.swift
//  DiscourseKit
//
//  Created by Tanner on 4/7/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Extensions
import Jsum

protocol Thing: DKCodable {
    var id: Int { get }
}

extension Thing {
    static var unavaliableID: Int { 0 }

    /// Protocols themselves cannot be extended, so default
    /// implementations are lost when you wish to "extend"
    /// default functionality instead of override it entirely.
    /// We work around this by namespacing default impls.
    static var thing_defaults: [String: Any] {
        return ["id": self.unavaliableID]
    }

    public static var defaultsByProperty: [String: Any] {
        return self.thing_defaults
    }
}
