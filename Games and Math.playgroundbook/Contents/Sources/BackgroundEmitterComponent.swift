//
//  BackgroundEmitterComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 18.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

final class BackgroundEmitterComponent<EntityType: EntityWithUpdatableComponents & EntityWithLayoutableComponents & EntityWithNodes>: BasicComponent<EntityType>, LayoutableComponent {
    
    fileprivate var rootNode = SKNode()
    fileprivate var viewSize: Size?
    
    
    fileprivate var baseBirthrate = Scalar(0)
    
    var node: UniversalEmitter? {
        didSet {
            oldValue?.removeFromParent()
            if let newEmitterNode = node {
                rootNode.addChild(newEmitterNode)
                layoutIfNeeded()
            }
        }
    }
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        
        entity.addUpdatableComponent(updatable)
        entity.addLayoutableComponent(self)
        entity.addNodeToScene(rootNode)
    }
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    
    let updateStep: UpdateStep = .willRenderScene
    
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        
    }
    
    func layout(_ viewSize: Size) {
        self.viewSize = viewSize
        layoutIfNeeded()
    }
    
    func layoutIfNeeded() {
        guard let viewSize = viewSize, let emitterNode = node else {
            return
        }
        let baseSize = Size(emitterNode.inital.particlePositionRange)
        
        let scaleFactor = viewSize.area/baseSize.area
        emitterNode.particleBirthRate = emitterNode.inital.particleBirthRate * CGFloat(scaleFactor)
        
        emitterNode.particlePositionRange = CGVector(viewSize)
        emitterNode.position = CGPoint(viewSize / 2)
        emitterNode.advanceSimulationTime(Foundation.TimeInterval(emitterNode.particleLifetime))
    }
}
