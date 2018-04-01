//
//  Interceptor.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 28.07.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol InterceptorProtocol: class {
    associatedtype ValueType
    associatedtype Interceptor
    associatedtype Callback
    
    var interceptors: [Interceptor] { get }
    
    func on(_ listener: AnyObject, callback: Callback)
    func off(_ listener: AnyObject)
    func some(_ value: ValueType) -> Bool
}


class Interceptor<T>: InterceptorProtocol {
    typealias ValueType = T
    typealias Callback = (ValueType) -> Bool
    typealias Interceptor = (AnyObject, Callback)
    fileprivate(set) var interceptors: [Interceptor] = []
    
    func on(_ listener: AnyObject, callback: @escaping Callback) {
        interceptors.append((listener, callback))
    }
    
    func off(_ listener: AnyObject) {
        interceptors = interceptors.filter {
            let (key, _) = $0
            return key !== listener
        }
    }
    
    fileprivate func invokeCallback(on interceptor: Interceptor, with value: ValueType) -> Bool {
        let (_, callback) = interceptor
        return callback(value)
    }
    
    func some(_ value: ValueType) -> Bool {
        for interceptor in interceptors {
            if invokeCallback(on: interceptor, with: value) {
                return true
            }
        }
        return false
    }
}

class WeakInterceptor<T>: InterceptorProtocol {
    typealias ValueType = T
    typealias Callback = (ValueType) -> Bool
    typealias Interceptor = (Weak<AnyObject>, Callback)
    fileprivate(set) var interceptors: [Interceptor] = []
    
    func on(_ listener: AnyObject, callback: @escaping Callback) {
        interceptors.append((Weak<AnyObject>(listener), callback))
    }
    
    func off(_ listener: AnyObject) {
        interceptors = interceptors.filter {
            let (interceptorReference, _) = $0
            return interceptorReference.value !== listener
        }
    }
    
    fileprivate func invokeCallback(on interceptor: Interceptor, with value: ValueType) -> Bool? {
        let (listenerReference, callback) = interceptor
        if listenerReference.hasReference {
            return callback(value)
        }
        return nil
    }
    
    func some(_ value: ValueType) -> Bool {
        for interceptor in interceptors {
            if let result = invokeCallback(on: interceptor, with: value),
                result == true {
                return true
            }
        }
        return false
    }
    func removeDeallocatedListener() {
        interceptors = interceptors.filter { $0.0.hasReference }
    }
}




