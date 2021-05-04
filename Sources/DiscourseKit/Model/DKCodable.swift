//
//  DKCodable.swift
//  Model
//
//  Created by Tanner on 4/21/19.
//

import Foundation
import Extensions
import Jsum

public protocol DKCodable: JSONCodable, Decodable { }

extension Array: DKCodable where Element: DKCodable { }
