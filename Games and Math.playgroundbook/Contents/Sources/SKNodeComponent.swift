//
//  SKNodeComponent.swift
//  EntityComponentSystem
//
//  Created by David Nadoba on 11.01.17.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

typealias SKNodeComponentEntityRequirements = EntityWithNodes & EntityWithUpdatableComponents & EntityWithPosition

protocol EntityWithSKNodeComponent: SKNodeComponentEntityRequirements {
    associatedtype NodeType: SKNode
    var nodeComponent: SKNodeComponent<Self, NodeType> { get }
}

final class SKNodeComponent<
    EntityType: SKNodeComponentEntityRequirements,
    NodeType: SKNode>:

    BasicComponent<EntityType>, UpdatableComponent {
    
    fileprivate let node: NodeType
    override init(){
        node = NodeType()
        super.init()
    }
    init(node: NodeType) {
        self.node = node
        super.init()
    }
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        entity.addNodeToScene(node)
        entity.addUpdatableComponent(updatable)
    }
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    var updateStep: UpdateStep = UpdateStep.willRenderScene
    func updateWithDeltaTime(_ seconds: Scalar) {
        node.position = CGPoint(entity.position)
    }
}

extension EntityWithSKNodeComponent {
    var node: NodeType {
        return nodeComponent.node
    }
}
