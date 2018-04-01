//
//  UpdatableSystem.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 04.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

enum UpdateStep: Int {
    //Update Execution Order
    case willEvaluateInput
    case evaluateInput
    case didEvaluateInput
    case update
    case willSimulatePhysics
    case simulatePhysics
    case didSimulatePhysics
    case executeTimer
    case willRenderScene
    
    static func enumarate() -> UpdateStepSequence {
        return UpdateStepSequence()
    }
    
    static var count: Int =  {
        // count elements
        return UpdateStep.enumarate().reduce(0) { (sum, _) in sum + 1 }
    }()
    
    struct UpdateStepSequence: Sequence {
        typealias Iterator = UpdateStepGenerator
        func makeIterator() -> Iterator {
            return UpdateStepGenerator()
        }
    }
    
    struct UpdateStepGenerator: IteratorProtocol {
        typealias Element = UpdateStep
        
        fileprivate var index = 0
        
        mutating func next() -> Element? {
            let element = UpdateStep(rawValue: index)
            index += 1
            return element
        }
    }
}


struct Updatable {
    let owner: AnyObject
    let updateWithDeltaTime: (Scalar) -> ()
    init(_ owner: AnyObject, _ closure: @escaping (Scalar) -> ()) {
        self.owner = owner
        updateWithDeltaTime = closure
    }
}

protocol UpdatableComponent: class {
    var updateStep: UpdateStep { get }
    var updatable: (UpdateStep, (TimeInterval) -> ()) { get }
    func updateWithDeltaTime(_ seconds: Scalar)
}

protocol EntityWithUpdatableComponents: Entity {
    var updatableComponents: [(UpdateStep, (TimeInterval) -> ())] { get set }
}

extension EntityWithUpdatableComponents {
    func addUpdatableComponent(_ updateable: (UpdateStep, (TimeInterval) -> ())) {
        updatableComponents.append(updateable)
    }
}


///Game with UpdateableSystem
protocol GameWithUpdatableSystem: Game {
    var currentTime: TimeInterval { get }
    var updatableSystem: UpdatableSystem { get }
}
private let normalDeltaTime: TimeInterval = 1/60

final class UpdatableSystem: BasicSystem {
    
    var updatablesInUpdateStep = ContiguousArray(repeating: ContiguousArray<Updatable>(), count: UpdateStep.count)
    var updatableFunctions = ContiguousArray<(Scalar) -> ()>()
    
    var maxDeltaTime: TimeInterval = 1/15
    
    var speed = Scalar(1)
    var currentSpeed: Scalar {
        return min(self.deltaTime * speed, maxDeltaTime)/self.deltaTime
    }
    
    fileprivate var currentTime: TimeInterval?
    fileprivate var deltaTime: TimeInterval = normalDeltaTime
    
    var updatableCount: Int {
        return updatablesInUpdateStep.reduce(0) {
            return $0 + $1.count
        }
    }
    
    func startUpdateLoop(_ currentTime: TimeInterval) {
        if let lastTime = self.currentTime {
            self.deltaTime = currentTime - lastTime
        } else {
            self.deltaTime = normalDeltaTime
        }
        self.currentTime = currentTime
    }
    
    func update(_ updateStep: UpdateStep) {
        let deltaTime = min(self.deltaTime * speed, maxDeltaTime)
        updateWithDeltaTime(deltaTime, updateStep: updateStep)
    }
    
    func updateWithDeltaTime(_ seconds: TimeInterval, updateStep: UpdateStep) {
        let updatables = updatablesInUpdateStep[updateStep.rawValue]
        for updatable in updatables {
            updatable.updateWithDeltaTime(seconds)
        }
    }
    
    override func addEntity(_ entity: Entity) {
        guard let entityWithUpdatableComponents = entity as? EntityWithUpdatableComponents else {
            return
        }
        for updatableComponent in entityWithUpdatableComponents.updatableComponents {
            let (updateStep, updateClosure) = updatableComponent
            
            addUpdatable(updateStep, updatable: Updatable(entity, updateClosure))
        }
        
    }
    
    func addUpdateableComponent(_ component: UpdatableComponent) {
        let (updateStep, updateClosure) = component.updatable
        addUpdatable(updateStep, updatable: Updatable(component, updateClosure))
    }
    
    func addUpdatable(_ updateStep: UpdateStep, updatable: Updatable) {
        updatablesInUpdateStep[updateStep.rawValue].append(updatable)
        updatableFunctions.append(updatable.updateWithDeltaTime)
    }
    
    override func removeEntity(_ entity: Entity) {
        guard let entityWithUpdatableComponents = entity as? EntityWithUpdatableComponents else {
            return
        }
        for updatableComponent in entityWithUpdatableComponents.updatableComponents {
            let (updateStep, _) = updatableComponent
            removeUpdatable(updateStep, owner: entity)
        }
    }
    
    func removeUpdateableComponent(_ component: UpdatableComponent) {
        let (updateStep, _) = component.updatable
        removeUpdatable(updateStep, owner: component)
    }
    
    func removeUpdatable(_ updateStep: UpdateStep, updatable: Updatable) {
        removeUpdatable(updateStep, owner: updatable.owner)
    }
    
    func removeUpdatable(_ updateStep: UpdateStep, owner: AnyObject) {
        guard let index = updatablesInUpdateStep[updateStep.rawValue].index(where: { $0.owner === owner }) else {
            return
        }
        
        updatablesInUpdateStep[updateStep.rawValue].remove(at: index)
        
    }
}


