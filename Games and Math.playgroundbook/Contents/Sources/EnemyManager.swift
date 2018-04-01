//
//  EnemyManager.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 28.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol GameWithEnemyManager: GameWithNodeSystem, GameWithTimerSystem {
    var enemyManager: EnemyManager<Self> { get }
}

protocol EnemyManagerEscapeDelegate: class {
    func enemyDidEscape()
}

protocol EnemyManagerRewardDelegate: class {
    func enemyDidDie()
}

struct EnemyManagerState: State {
    var spawned: Int
    var died: Int
    var escaped: Int
    
    var alive: Int {
        return spawned - died - escaped
    }
    
    
    
    func enemySpawned() -> EnemyManagerState {
        var newState = self
        newState.spawned += 1
        return newState
    }
    
    func enemyDied() -> EnemyManagerState {
        var newState = self
        newState.died += 1
        return newState
    }
    func enemyEscaped() -> EnemyManagerState {
        var newState = self
        newState.escaped += 1
        return newState
    }
}

func ==(lhs: EnemyManagerState, rhs: EnemyManagerState) -> Bool {
    return lhs.spawned == rhs.spawned &&
        lhs.died == rhs.died &&
        lhs.escaped == rhs.escaped
}

final class EnemyManager<GameType: GameWithNodeSystem & GameWithTimerSystem>: BasicEntityWithGame<GameType>, StateMachine, EnemyDelegate {
    
    weak var escapeDelegate: EnemyManagerEscapeDelegate?
    weak var rewardDelegate: EnemyManagerRewardDelegate?
    
    
    var currentState = EnemyManagerState(spawned: 0, died: 0, escaped: 0)
    let didChangeState = WeakEvent<StateChangeEvent<EnemyManagerState>>()
    
    func add(_ enemy: Enemy<GameType>) {
        enemy.delegate = self
        game?.addEntityWithGame(enemy)
        
        updateToStateIfNeeded(currentState.enemySpawned())
    }
    
    func enemyDidDie() {
        updateToStateIfNeeded(currentState.enemyDied())
        rewardDelegate?.enemyDidDie()
        
    }
    func enemyDidReachEnd() {
        updateToStateIfNeeded(currentState.enemyEscaped())
        escapeDelegate?.enemyDidEscape()
    }
}
