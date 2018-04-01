//
//  File.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 31.07.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol State: Equatable {
    
}

struct StateChangeEvent<StateType: State> {
    let previousState: StateType
    let currentState: StateType
    
    init(from previousState: StateType, to currentState: StateType) {
        self.previousState = previousState
        self.currentState = currentState
    }
}

protocol StateMachine: class {
    associatedtype StateType: State
    
    var currentState: StateType { get set }
    
    var didChangeState: WeakEvent<StateChangeEvent<StateType>> { get }
}

protocol ExternalStateObserver: class {
    func externalStateHasChanged()
}

extension StateMachine {
    func updateToStateIfNeeded(_ nextState: StateType) {
        if currentState != nextState {
            let previousState = currentState
            currentState = nextState
            let stateChangeEvent = StateChangeEvent<StateType>(from: previousState, to: currentState)
            didChangeState.emit(stateChangeEvent)
        }
    }
    func addStateObserver<T: ExternalStateObserver>(_ observer: T) {
        didChangeState.on(observer) { [unowned observer] _ in
            observer.externalStateHasChanged()
        }
    }
    func removeStateObserver<T: ExternalStateObserver>(_ observer: T) {
        didChangeState.off(observer)
    }
}
