//
//  SKSceneSystem.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 04.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

enum NodeLayer {
    case gameplay
    case screen
}

struct NodeInfo {
    let node: SKNode
    let layer: NodeLayer
    
    init(node: SKNode, on layer: NodeLayer) {
        self.node = node
        self.layer = layer
    }
}

protocol EntityWithNodes: Entity {
    
    var nodes: [NodeInfo] { get set }
    func addNodeToScene(_ node: SKNode)
    func addNodeToScene(_ node: SKNode, on layer: NodeLayer)
    /**
     add node as a child to the scene
     - parameters:
        - node: SKNode to add
        - relatedToEntity: if it's true it will automaticly be added to and removed from the scene graph as the entity is added and removed from the game
     */
    func addNodeToScene(_ node: SKNode, on layer: NodeLayer, relatedToEntity: Bool)
    func addRelation(to node: SKNode, on layer: NodeLayer)
    func removeRelation(from node: SKNode) -> Bool
}

extension EntityWithNodes {
    func addNodeToScene(_ node: SKNode) {
        addNodeToScene(node, on: .gameplay, relatedToEntity: true)
    }
    func addNodeToScene(_ node: SKNode, on layer: NodeLayer) {
        addNodeToScene(node, on: layer, relatedToEntity: true)
    }
}

extension EntityWithGame where Self: EntityWithNodes, GameType: GameWithNodeSystem {
    func addNodeToScene(_ node: SKNode, on layer: NodeLayer, relatedToEntity: Bool) {
        if relatedToEntity {
            addRelation(to: node, on: layer)
        }
        
        game?.nodeSystem.addNode(node, on: layer)
    }
    func addRelation(to node: SKNode, on layer: NodeLayer) {
        _ = removeRelation(from: node)
        nodes.append(NodeInfo(node: node, on: layer))
    }
    
    func removeRelation(from node: SKNode) -> Bool {
        if let index = nodes.map({ $0.node }).index(of: node) {
            nodes.remove(at: index)
            return true
        }
        return false
    }
}
// FIXME: with Xcode 9.3 Beta 4 the extension above is not enoght and the compile crashes with the following error:
// Segmentation fault: 11
// While emitting IR SIL function "@_T021EntityComponentSystem05BasicA8WithGameCyxGAA0aE5NodesA2aEP14removeRelationSbSo6SKNodeC4from_tFTW".
// for 'removeRelation(from:)' at /Users/dnadoba/Repositories/entity-component-system/EntityComponentSystem/NodeSystem.swift:65:5

extension BasicEntityWithGame {
    func addNodeToScene(_ node: SKNode, on layer: NodeLayer, relatedToEntity: Bool) {
        if relatedToEntity {
            addRelation(to: node, on: layer)
        }
        
        game?.nodeSystem.addNode(node, on: layer)
    }
    func addRelation(to node: SKNode, on layer: NodeLayer) {
        _ = removeRelation(from: node)
        nodes.append(NodeInfo(node: node, on: layer))
    }
    
    func removeRelation(from node: SKNode) -> Bool {
        if let index = nodes.map({ $0.node }).index(of: node) {
            nodes.remove(at: index)
            return true
        }
        return false
    }
}

protocol GameWithNodeSystem: GameWithUpdatableSystem, GameWithGameScene {
    var nodeSystem: NodeSystem { get }
}

extension GameWithNodeSystem {
    var scene: GameScene  {
        return nodeSystem.scene
    }
    
    var paused: Bool {
        return scene.isPaused
    }
    
    func pause() {
        scene.isPaused = true
    }
    
    func resume() {
        scene.isPaused = false
    }
}

final class NodeSystem: BasicSystem, EntityWithUpdatableComponents, UpdatableComponent {
    let scene: GameScene
    
    var updatableComponents: [(UpdateStep, (TimeInterval) -> ())] = []
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    convenience override init() {
        self.init(scene: GameScene())
    }
    
    var size: Size {
        return Size(scene.size)
    }
    var ratio: Scalar {
        return size.width / size.height
    }
    
    override func addEntity(_ entity: Entity) {
        guard let entityWithNodes = entity as? EntityWithNodes else {
            return
        }
        for nodeInfo in entityWithNodes.nodes {
            addNode(nodeInfo.node, on: nodeInfo.layer)
        }
    }
    override func removeEntity(_ entity: Entity) {
        guard let entityWithNodes = entity as? EntityWithNodes else {
            return
        }
        for nodeInfo in entityWithNodes.nodes {
            nodeInfo.node.removeFromParent()
        }
    }
    
    let updateStep = UpdateStep.willEvaluateInput
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        //scene.speed =
    }
    
    func convertPoint(_ fromView: Vector) -> Vector {
        return Vector(scene.convertPoint(fromView: CGPoint(fromView)))
    }
    
    func addNode(_ node: SKNode, on layer: NodeLayer = .gameplay) {
        if layer == .screen, let camera = scene.camera {
            camera.addChild(node)
        } else {
            scene.addChild(node)
        }
        
    }
}

extension GameWithNodeSystem {
    
    func levelFileNameSuffix() -> String {
        let displayRatio16to9:Scalar = 16/9
        let displayRation4to3:Scalar = 4/3
        let average:Scalar = (displayRatio16to9 + displayRation4to3)/2
        return nodeSystem.ratio > average ? "-16to9" : "-4to3"
    }
}
