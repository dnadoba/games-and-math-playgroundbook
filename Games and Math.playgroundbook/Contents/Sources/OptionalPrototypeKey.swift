//
//  OptionalPrototypeKey.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 25.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

struct OptionalPrototypeKey<ValueType>: CustomStringConvertible {
    let key: String
    
    init(_ key: String) {
        self.key = key
    }
    
    init(_ key: PrototypeKey<ValueType>) {
        self.key = key.key
    }
    
    var description: String {
        return "\(key)<Optinal(\(ValueType.self))>"
    }
}

extension Prototype {
    func hasKey<ValueType>(_ key: OptionalPrototypeKey<ValueType>) -> Bool {
        if (values.object(forKey: key.key) as? ValueType) != nil {
            return true
        } else if let prototype = prototype,
            prototype.hasKey(key) {
            return true
        } else {
            return false
        }
    }
    
    func valueForKey<ValueType>(_ key: OptionalPrototypeKey<ValueType>) -> ValueType? {
        if let value = values[key.key] as? ValueType {
            return value
        } else if let prototype = prototype {
            return prototype.valueForKey(key)
        } else {
            return nil
        }
    }
    
    func validateKey<ValueType>(_ key: OptionalPrototypeKey<ValueType>) -> String? {
        if let value = values.object(forKey: key.key) {
            // fi the key exists, check the type of the value
            guard value is ValueType else {
                return key.description
            }
        } else if let prototype = prototype {
            return prototype.validateKey(key)
        }
        return nil
    }
}
