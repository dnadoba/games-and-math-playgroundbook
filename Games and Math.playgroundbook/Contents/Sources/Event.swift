//
//  Observer.swift
//  tower-defence
//
//  Created by David Jonas Nadoba on 29.12.15.
//  Copyright © 2015 David Nadoba. All rights reserved.
//

import Foundation

protocol EventProtocol: class {
    associatedtype ValueType
    associatedtype Observer
    associatedtype Callback
    
    var observers: [Observer] { get }
    
    func on(_ listener: AnyObject, callback: Callback)
    func off(_ listener: AnyObject)
    func emit(_ value: ValueType)
    func once(_ listener: AnyObject, callback: Callback)
}

class Event<T>: EventProtocol {
    typealias ValueType = T
    typealias Callback = (ValueType) -> ()
    typealias Observer = (AnyObject, Callback)
    fileprivate(set) var observers: [Observer] = []
    
    func on(_ listener: AnyObject, callback: @escaping Callback) {
        observers.append((listener, callback))
    }
    
    func off(_ listener: AnyObject) {
        observers = observers.filter {
            let (key, _) = $0
            return key !== listener
        }
    }

    fileprivate func invokeCallback(on observer: Observer, with value: ValueType) {
        let (_, callback) = observer
        callback(value)
    }
    
    func emit(_ value: ValueType) {
        for observer in observers {
            invokeCallback(on: observer, with: value)
        }
    }
    
    func once(_ listener: AnyObject, callback: @escaping Callback) {
        self.on(listener) { [unowned self] _ in
            self.off(listener)
        }
        self.on(listener, callback: callback)
    }
}

class WeakEvent<T>: EventProtocol {
    typealias ValueType = T
    typealias Callback = (ValueType) -> ()
    typealias Observer = (Weak<AnyObject>, Callback)
    
    fileprivate(set) var observers: [Observer] = []
    
    func on(_ listener: AnyObject, callback: @escaping Callback) {
        observers.append((Weak<AnyObject>(listener), callback))
    }
    
    func off(_ listener: AnyObject) {
        observers = observers.filter {
            let (listenerReference, _) = $0
            return listenerReference.value !== listener
        }
    }
    
    fileprivate func invokeCallback(on observer: Observer, with value: ValueType) {
        let (listenerReference, callback) = observer
        if listenerReference.hasReference {
            callback(value)
        }
    }
    func emit(_ value: ValueType) {
        for observer in observers {
            invokeCallback(on: observer, with: value)
        }
    }
    
    func once(_ listener: AnyObject, callback: @escaping Callback) {
        self.on(listener) { [unowned self] _ in
            self.off(listener)
        }
        self.on(listener, callback: callback)
    }
    
    func removeDeallocatedListener() {
        observers = observers.filter { $0.0.hasReference }
    }
}


