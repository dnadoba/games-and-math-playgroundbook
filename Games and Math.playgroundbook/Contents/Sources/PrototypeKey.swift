//
//  PrototypeKey.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 25.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

struct PrototypeKey<ValueType>: CustomStringConvertible {
    let key: String
    init(_ key: String) {
        self.key = key
    }
    init(_ key: OptionalPrototypeKey<ValueType>) {
        self.key = key.key
    }
    
    var description: String {
        return "\(key)<\(ValueType.self)>"
    }
}

extension Prototype {
    
    func hasKey<ValueType>(_ key: PrototypeKey<ValueType>) -> Bool {
        if (values.object(forKey: key.key) as? ValueType) != nil {
            return true
        } else if let prototype = prototype,
            prototype.hasKey(key) {
            return true
        } else {
            return false
        }
    }
    
    func valueForKey<ValueType>(_ key: PrototypeKey<ValueType>) -> ValueType {
        guard let value = valueForKey(OptionalPrototypeKey(key)) else {
            fatalError("\(self) does not have a value for key \(key)")
        }
        return value
    }
    
    func optinalValueForKey<ValueType>(_ key: PrototypeKey<ValueType>) -> ValueType? {
        if let value = values[key.key] as? ValueType {
            return value
        } else if let prototype = prototype {
            return prototype.optinalValueForKey(key)
        } else {
            return nil
        }
    }
    
    func validateKey<ValueType>(_ key: PrototypeKey<ValueType>) -> String? {
        if hasKey(key) {
            return nil
        } else {
            return key.description
        }
    }
}

