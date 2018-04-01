//
//  Prototype.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 25.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol Prototype: class, CustomStringConvertible {
    var itemIndex: Int { get }
    var name: String { get }
    var prototype: Self? { get set }
    var values: NSDictionary { get }
    func validateKeys() -> [String?]
    
    init(itemIndex: Int, name: String, values: NSDictionary)
    
    func hasKey<ValueType>(_ key: PrototypeKey<ValueType>) -> Bool
    func valueForKey<ValueType>(_ key: PrototypeKey<ValueType>) -> ValueType
    
    func hasKey<ValueType>(_ key: OptionalPrototypeKey<ValueType>) -> Bool
    func valueForKey<ValueType>(_ key: OptionalPrototypeKey<ValueType>) -> ValueType?
}

extension Prototype {
    var description: String {
        return "Prototype(itemIndex: \(itemIndex), name: \(name))"
    }
    
    var hashValue: Int {
        return name.hashValue
    }
}
