//
//  FireworkSystem.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 29.07.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit
import simd

protocol GameWithFireworkSystem: GameWithNodeSystem, GameWithTimerSystem {
    var fireworkSystem: FireworkSystem<Self> { get }
}

private let minSpeed:Float = 0.05

final class FireworkSystem<GameType: GameWithNodeSystem & GameWithTimerSystem>: BasicSystemWithGame<GameType>, EntityWithNodes {
    
    var nodes: [NodeInfo] = []
    
    fileprivate let bitMask: UInt32 = 1
    
    override func initComponents() {
        super.initComponents()
        
        let field = SKFieldNode.customField { [minSpeed = minSpeed] (position3D, velocity3D, _, _, _) -> vector_float3  in
            let velocity = vector2(velocity3D.x, velocity3D.y)
            let speed = length(velocity)
            
            var force =  speed > minSpeed ? -velocity * 3 : vector_float2()
            
            
            force += vector_float2(0, -0.1)
            
             
            return vector_float3(force.x, force.y, 0)
        }
        
        field.categoryBitMask = bitMask
        
        addNodeToScene(field)
    }
    
    override func addEntity(_ entity: Entity) {
        guard let firework = entity as? Firework<GameType> else {
            return
        }
        firework.setFireworkFieldBitMask(bitMask)
    }
}


