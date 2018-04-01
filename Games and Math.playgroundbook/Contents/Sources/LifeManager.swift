//
//  LifeEntity.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 30.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation


protocol GameWithLifeManager: GameWithNodeSystem {
    var lifeManager: LifeManager<Self> { get }
}

struct LifeState: State {
    let lifePoints: Int
    
    var isAlive: Bool {
        return lifePoints > 0
    }
    
    init(lifePoints: Int) {
        self.lifePoints = max(0, lifePoints)
    }
}

func ==(lhs: LifeState, rhs: LifeState) -> Bool {
    return lhs.lifePoints == rhs.lifePoints
}


final class LifeManager<GameType: GameWithNodeSystem>: BasicEntityWithGame<GameType>, StateMachine, EnemyManagerEscapeDelegate {
    
    var currentState = LifeState(lifePoints: 20)
    
    let didChangeState = WeakEvent<StateChangeEvent<LifeState>>()

    func enemyDidEscape() {
        let newState = LifeState(lifePoints: currentState.lifePoints - 1)
        updateToStateIfNeeded(newState)
    }
}
