//
//  BasicEntity.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 16.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

class BasicEntity: Entity, TransformableEntity, EntityWithUpdatableComponents {
    
    var isInGame = false
    final var updatableComponents: [(UpdateStep, (TimeInterval) -> ())] = []
    
    final var position = PositionComponent(0, 0)
    final var rotation = RotationComponent(0)
    final var scale = ScaleComponent(1, 1)
    
    init() {
        initComponents()
    }
    
    func initComponents() {}
}

class BasicEntityWithGame<GameType: GameWithNodeSystem>: BasicEntity, EntityWithGame, EntityWithNodes, EntityWithRootNode {
    weak var game: GameType?
    
    final var nodes: [NodeInfo] = []
    
    final let rootNode = RootNodeComponent<BasicEntityWithGame<GameType>>()
    
    override func initComponents() {
        super.initComponents()
        rootNode.initComponent(withEntity: self)
    }
    
    func added(to game: GameType) {}
    func removed(from game: GameType) {}
}
