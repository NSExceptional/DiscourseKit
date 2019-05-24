//
//  Collection+Where.swift
//  Extensions
//
//  Created by Tanner Bennett on 5/23/19.
//

import Foundation

extension Collection {
    @inlinable public func `where`(_ keyPath: KeyPath<Element, Bool>) -> Element? {
        return self.filter { $0[keyPath: keyPath] == true }.first
    }
    
    @inlinable public func `where`<T: Equatable>(_ keyPath: KeyPath<Element, T>, is value: T) -> Element? {
        return self.filter { $0[keyPath: keyPath] == value }.first
    }
}
