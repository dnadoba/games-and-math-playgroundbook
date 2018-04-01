//
//  BasicSKNodeEntity.swift
//  EntityComponentSystem
//
//  Created by David Nadoba on 11.01.17.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

final class BasicSKEntity<
    GameType: GameWithNodeSystem,
    NodeType: SKNode>:
    
    EntityWithGame, EntityWithSKNodeComponent {
    
    weak var game: GameType?
    var nodes: [NodeInfo] = []
    var updatableComponents: [(UpdateStep, (TimeInterval) -> ())] = []
    
    var position = Vector2()
    
    let nodeComponent: SKNodeComponent<BasicSKEntity, NodeType>
    
    init() {
        nodeComponent = SKNodeComponent<BasicSKEntity, NodeType>(node: NodeType())
        initComponents()
    }
    init(node: NodeType) {
        nodeComponent = SKNodeComponent<BasicSKEntity, NodeType>(node: node)
        initComponents()
    }
    
    func initComponents() {
        nodeComponent.initComponent(withEntity: self)
    }
    
    func added(to game: GameType) {}
    func removed(from game: GameType) {}
}
