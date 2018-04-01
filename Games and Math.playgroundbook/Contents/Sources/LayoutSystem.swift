//
//  LayoutSystem.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 11.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol LayoutableComponent: ClassComponent {
    func layout(_ viewSize: Size)
}

protocol EntityWithLayoutableComponents: Entity {
    var layoutableComponents: [LayoutableComponent] { get set }
}

extension EntityWithLayoutableComponents {
    func addLayoutableComponent(_ component: LayoutableComponent) {
        layoutableComponents.append(component)
    }
}

final class LayoutSystem<GameType: GameWithUpdatableSystem>: BasicSystemWithGame<GameType>, EntityWithUpdatableComponents, UpdatableComponent {
    
    var updatableComponents: [(UpdateStep, (TimeInterval) -> ())] = []
    
    var viewSize = Size()
    var oldViewSize = Size()
    
    fileprivate var needsLayout = true
    
    fileprivate var layoutableComponents: [LayoutableComponent] = []
    
    override func initComponents() {
        super.initComponents()
        addUpdatableComponent(updatable)
    }
    
    let updateStep = UpdateStep.willEvaluateInput
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        // if the size has changed we need to update all components
        guard needsLayout else {
            return
        }
        needsLayout = false
        
        let viewSize = self.viewSize
        for component in layoutableComponents {
            component.layout(viewSize)
        }
        
    }
    
    override func addEntity(_ entity: Entity) {
        guard let entity = entity as? EntityWithLayoutableComponents else {
            return
        }
        
        entity.layoutableComponents.forEach(addLayoutableComponent)
    }
    
    override func removeEntity(_ entity: Entity) {
        guard let entity = entity as? EntityWithLayoutableComponents else {
            return
        }
        
        entity.layoutableComponents.forEach(removeLayoutableComponent)
    }
    
    func addLayoutableComponent(_ component: LayoutableComponent) {
        if !needsLayout {
            component.layout(viewSize)
        }
        layoutableComponents.append(component)
    }
    
    func removeLayoutableComponent(_ component: LayoutableComponent) {
        //remove in from layoutable components
        if let index = layoutableComponents.index(where: { $0 === component }) {
            layoutableComponents.remove(at: index)
        }
    }
    
    func didChangeSize(_ viewSize: Size, oldViewSize: Size) {
        self.viewSize = viewSize
        self.oldViewSize = oldViewSize
        needsLayout = true
    }
}



