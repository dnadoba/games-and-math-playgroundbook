//
//  MoneyManager.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 30.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
typealias Money = Int

protocol GameWithMoneyManager: GameWithNodeSystem {
    var moneyManager: MoneyManager<Self> { get }
}

struct MoneyState: State {
    let money: Int
    init(money: Int) {
        self.money = money
    }
    
    fileprivate func moneyEarned(_ amount: Money) -> MoneyState {
        return MoneyState(money: money + amount)
    }
    
    fileprivate func canSpend(money amount: Money) -> Bool {
        return money >= amount
    }
    
    fileprivate func spend(money amount: Money) -> MoneyState? {
        guard canSpend(money: amount) else {
            return nil
        }
        return MoneyState(money: money - amount)
    }
}

func ==(lhs: MoneyState, rhs: MoneyState) -> Bool {
    return lhs.money == rhs.money
}

final class MoneyManager<GameType: GameWithNodeSystem>: BasicEntityWithGame<GameType>, StateMachine, EnemyManagerRewardDelegate {
    
    var currentState = MoneyState(money: 260)
    
    let didChangeState = WeakEvent<StateChangeEvent<MoneyState>>()
    
    func addMoney(_ amount: Int) {
        let nextState = currentState.moneyEarned(amount)
        updateToStateIfNeeded(nextState)
    }
    
    func enemyDidDie() {
        let nextState = currentState.moneyEarned(5)
        updateToStateIfNeeded(nextState)
    }
    
    func canBuyItem(for price: Money) -> Bool {
        return currentState.canSpend(money: price)
    }
    
    func buyItem(for price: Money) -> Bool {
        guard let nextState = currentState.spend(money: price) else {
            return false
        }
        updateToStateIfNeeded(nextState)
        return true
    }
}
