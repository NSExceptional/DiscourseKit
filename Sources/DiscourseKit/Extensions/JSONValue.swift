//
//  JSONValue.swift
//  DiscourseKit
//
//  Created by Tanner on 3/31/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation

public protocol JSONValue: CVarArg { }

extension String : JSONValue { }
extension NSString : JSONValue { }
extension Date : JSONValue { }
extension Int : JSONValue { }
extension Bool : JSONValue { }
extension Double : JSONValue { }
extension Float : JSONValue { }
extension Array : JSONValue { }
extension Dictionary : JSONValue { }
extension NSArray : JSONValue { }
extension NSDictionary : JSONValue { }
extension NSNumber : JSONValue { }
extension NSNull : JSONValue { }
