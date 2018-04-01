//
//  SKNodeComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 04.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

protocol RootNode {
    var zIndexOffset: Scalar { get set }
    func addChild(_ node: SKNode)
}

protocol EntityWithRootNode: TransformableEntity, EntityWithUpdatableComponents, EntityWithNodes {
    associatedtype RootNodeType: RootNode
    var rootNode: RootNodeType { get }
}

extension EntityWithRootNode {
    func addChild(_ node: SKNode) {
        rootNode.addChild(node)
    }
}

final class RootNodeComponent<EntityType: TransformableEntity & EntityWithUpdatableComponents & EntityWithNodes>: BasicComponent<EntityType>, UpdatableComponent, RootNode {
    
    var layer = NodeLayer.gameplay {
        didSet {
            removeFromScene()
            addToScene()
        }
    }
    /**
     if false the node will no longer be added or removed from the scene if the entity is added or remove from a game
     */
    var relatedToEntity: Bool = true {
        didSet {
            guard oldValue != relatedToEntity else {
                return
            }
            switch relatedToEntity {
            case true: addRelation()
            case false: removeRelation()
            }
        }
    }
    
    fileprivate let node = SKNode()
    
    var zIndexOffset: Scalar = 0
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        
        entity.addUpdatableComponent(updatable)
        
        entity.addNodeToScene(self.node, on: layer)
    }

    
    let updateStep = UpdateStep.willRenderScene
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        
        self.node.position = CGPoint(entity.position)
        self.node.zRotation = CGFloat(entity.rotation)
        var scale = entity.scale
        self.node.xScale = CGFloat(scale.x)
        self.node.yScale = CGFloat(scale.y)
        self.node.zPosition = CGFloat(zIndexOffset) - self.node.position.y
    }
    
    func addChild(_ node: SKNode) {
        self.node.addChild(node)
    }
    fileprivate func addRelation() {
        entity.addRelation(to: node, on: layer)
    }
    
    fileprivate func removeRelation() {
        _ = entity.removeRelation(from: node)
    }
    
    
    func addToScene() {
        entity.addNodeToScene(node, on: layer, relatedToEntity: relatedToEntity)
    }
    func removeFromScene() {
        removeRelation()
        node.removeFromParent()
    }
    
    func playSound(_ soundFile: String) {
        let playSound = SKAction.playSoundFileNamed(soundFile, waitForCompletion: false)
        node.run(playSound)
    }
}
