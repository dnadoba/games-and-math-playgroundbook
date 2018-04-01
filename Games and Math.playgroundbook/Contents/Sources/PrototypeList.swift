//
//  EntityModel.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 21.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

struct PrototypeDefaultKeys {
    static let name = OptionalPrototypeKey<String>("name")
    static let prototype = OptionalPrototypeKey<String>("prototype")
}



class PrototypeList<PrototypeType: Prototype>: CustomStringConvertible, Sequence {
    
    fileprivate var prototypes: Dictionary<String, PrototypeType> = [:]
    fileprivate var prototypeList: [PrototypeType] = []
    
    init(fileNamed fileName: String) {
        description = "PrototypeList(fromFile: \(fileName))"
        
        let propertyList = loadPropertyList(fileName)
        
        let (prototypeList, prototypes) = load(propertyList)
        self.prototypeList = prototypeList
        self.prototypes = prototypes
    }
    
    init(withPropertyList propertyList: [NSDictionary], inPrototype parentPrototype: String) {
        description = "PrototypeList(propertyListInPrototype: \(parentPrototype))"
        
        let (prototypeList, prototypes) = load(propertyList)
        self.prototypeList = prototypeList
        self.prototypes = prototypes
    }
    
    let description: String
    
    fileprivate func load(_ propertyList: [NSDictionary]) -> ([PrototypeType], Dictionary<String, PrototypeType>) {
        
        checkDefaultRequiredKeys(propertyList)
        
        let prototypeList = propertyList.enumerated().map { (itemIndex, values) -> PrototypeType in
            let name = values[PrototypeDefaultKeys.name.key] as? String ?? defaultNameForPrototype(atIndex: itemIndex)
            return PrototypeType(itemIndex: itemIndex, name: name, values: values)
        }
        
        var prototypes = Dictionary<String, PrototypeType>(minimumCapacity: prototypeList.count)
        
        for prototype in prototypeList {
            prototypes[prototype.name] = prototype
        }
        
        for prototype in prototypeList {
            if let parrentId = prototype.valueForKey(PrototypeDefaultKeys.prototype) {
                prototype.prototype = prototypes[parrentId]
            }
        }
        checkRequiredKeys(prototypeList)
        return (prototypeList, prototypes)
    }
    
    fileprivate func defaultNameForPrototype(atIndex index: Int) -> String {
        return "PrototypeWithoutName(itemIndex: \(index))"
    }
    
    fileprivate func checkDefaultRequiredKeys(_ propertyList: [NSDictionary]) {
        let errors = propertyList.enumerated().flatMap { (index, values) -> String? in
            if let name = values.object(forKey: PrototypeDefaultKeys.name.key) {
                guard name is String else {
                    return "Prototype's name at item index \(index) is not a String"
                }
            }
            if let prototypeName = values.object(forKey: PrototypeDefaultKeys.prototype.key) {
                guard prototypeName is String else {
                    return "Prototype at item index \(index) has a prototype key but the type of the value is not a String"
                }
            }
            return nil
        }
        guard errors.count == 0 else {
            fatalError(errors.joined(separator: "\n"))
        }
    }
    
    fileprivate func checkRequiredKeys(_ models: [PrototypeType]) {
        var missingKeysForModel = Dictionary<String, [String]>()
        for model in models {
            let name = model.name
            let missingKeys = model.validateKeys().flatMap({$0})
            if missingKeys.count > 0 {
                missingKeysForModel[name] = missingKeys
            }
        }
        guard missingKeysForModel.count == 0 else {
            fatalError("keys are missing or values have a wrong type in \(self):  \(missingKeysForModel)")
        }
    }
    
    fileprivate func loadPropertyList(_ fileName: String) -> [NSDictionary] {
        
        guard let path = Bundle.main.path(forResource: fileName, ofType: "plist"),
            let propertyList = NSArray(contentsOfFile: path) else {
            fatalError("Could not load \(self), file does probably not exists in main bundle")
        }
        return propertyList.flatMap { $0 as? NSDictionary }
    }
    
    func prototypeByName(_ name: String) -> PrototypeType? {
        return prototypes[name]
    }
    
    func list() -> [PrototypeType] {
        return prototypeList
    }

    func makeIterator() -> IndexingIterator<[PrototypeType]> {
        return prototypeList.makeIterator()
    }
    
    subscript(name: String) -> PrototypeType {
        guard let prototype = prototypeByName(name) else {
            fatalError("prototype with name \(name) does not exists in \(self)")
        }
        return prototype
    }
}
