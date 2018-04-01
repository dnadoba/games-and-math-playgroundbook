//
//  StateEffectComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 02.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol EffectableEntity {
    func apply(stateEffect effect: StateEffect, fromSource source: StateEffectSource)
}

protocol EntityWithStateEffectManagerComponent: EntityWithGame, EntityWithUpdatableComponents, EntityWithAllStateAttributes where GameType: GameWithTimerSystem {
    
    var effectManager: StateEffectManagerComponent<GameType, Self> { get }
}

extension EntityWithStateEffectManagerComponent {
    func apply(stateEffect effect: StateEffect, fromSource source: StateEffectSource) {
        effectManager.apply(stateEffect: effect, fromSource: source)
    }
}


private protocol StateEffectFromSource {
    associatedtype StateEffectType: StateEffectWithAttribute
    var effect: StateEffectType { get }
    var source: StateEffectSource { get }
}

private extension Array where Element: StateEffectFromSource {
    mutating func remove(_ source: StateEffectSource) {
        self = self.filter { $0.source !== source }
    }
}

private protocol StateEffectFromSourceForDuration: StateEffectFromSource {
    var timeoutTime: TimeInterval { get }
}

private extension StateEffectFromSourceForDuration {
    func isExpired(_ currentTime: TimeInterval) -> Bool{
        return currentTime >= timeoutTime
    }
}

private struct StateEffectOneTime<StateEffectType: StateEffectWithAmount>: StateEffectFromSource {
    let effect: StateEffectType
    let source: StateEffectSource
    init(_ effect: StateEffectType, fromSource source: StateEffectSource) {
        self.effect = effect
        self.source = source
    }
    
    func apply<EntityType: EntityWithAllStateAttributes>(toEntity entity: EntityType) {
        let amount = effect.amount
        effect.attribute.change(onEnitty: entity, by: amount, fromSource: source)
    }
}

private struct StateEffectOverTime<StateEffectType: StateEffectWithDuration & StateEffectWithAmount>: StateEffectFromSourceForDuration {
    let effect: StateEffectType
    let source: StateEffectSource
    let timeoutTime: TimeInterval
    init(_ effect: StateEffectType, currentTime: TimeInterval, fromSource source: StateEffectSource) {
        self.effect = effect
        self.source = source
        self.timeoutTime = currentTime + effect.duration
    }
    
    func apply<EntityType: EntityWithAllStateAttributes>(toEntity entity: EntityType, withDeltaTime seconds: TimeInterval, andCurrentTime currentTime: TimeInterval) {
        let secondsLeft = max(timeoutTime - currentTime, 0)
        let amountToApply = min(secondsLeft, seconds) * effect.amount
        effect.attribute.change(onEnitty: entity, by: amountToApply, fromSource: source)
    }
}

private struct StateEffectForTime<StateEffectType: StateEffectWithDuration & StateEffectWithAmount>: StateEffectFromSourceForDuration {
    let effect: StateEffectType
    let source: StateEffectSource
    let timeoutTime: TimeInterval
    init(_ effect: StateEffectType, currentTime: TimeInterval, fromSource source: StateEffectSource) {
        self.effect = effect
        self.source = source
        self.timeoutTime = currentTime + effect.duration
    }
    func apply<EntityType: EntityWithAllStateAttributes>(toEntity entity: EntityType) {
        
        effect.attribute.change(onEnitty: entity, by: effect.amount, fromSource: source)
    }
}

struct VisualStateEffect: OptionSet {
    let rawValue: Int
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    static let None = VisualStateEffect(rawValue: 0)
    static let Throttle = VisualStateEffect(rawValue: 1)
    static let Fire = VisualStateEffect(rawValue: 2)
}

protocol StateEffectManagerDelegate: class {
    func addVisualEffect(_ effect: VisualStateEffect)
    func removeVisualEffect(_ effect: VisualStateEffect)
}

final class StateEffectManagerComponent<GameType: GameWithTimerSystem, EntityType: EntityWithGame & EntityWithAllStateAttributes & EntityWithUpdatableComponents>: BasicComponentWithGame<GameType, EntityType>, UpdatableComponent where EntityType.GameType == GameType {
    
    weak var delegate: StateEffectManagerDelegate?
    
    fileprivate var appliedVisalEffects: VisualStateEffect = VisualStateEffect.None
    
    fileprivate var damageStateEffects = [StateEffectOneTime<DamageStateEffect>]()
    fileprivate var throttleStateEffects = [StateEffectForTime<ThrottleStateEffect>]()
    fileprivate var fireStateEffects = [StateEffectOverTime<FireStateEffect>]()
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        entity.addUpdatableComponent(updatable)
    }
    
    var isEffactable: Bool {
        return entity.health.isAlive
    }
    
    func apply(stateEffect effect: StateEffect, fromSource source: StateEffectSource) {
        guard isEffactable,
            let game = self.game else {
            return
        }
        switch effect{
        case .damage(let damageStateEffect):
            let effectOneTime = StateEffectOneTime(damageStateEffect, fromSource: source)
            damageStateEffects.append(effectOneTime)
        case .throttle(let throttleStateEffect):
            throttleStateEffects.remove(source)
            let effectForTime = StateEffectForTime(throttleStateEffect, currentTime: game.timerSystem.currentTime, fromSource: source)
            throttleStateEffects.append(effectForTime)
        case .fire(let fireStateEffect):
            fireStateEffects.remove(source)
            let effectOverTime = StateEffectOverTime(fireStateEffect, currentTime: game.timerSystem.currentTime, fromSource: source)
            fireStateEffects.append(effectOverTime)
        }
    }
    
    let updateStep = UpdateStep.didSimulatePhysics
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        if !isEffactable {
            removeAllEffects()
        }
        guard let game = self.game else {
            return
        }
        let currentTime = game.timerSystem.currentTime
        resetStateEffects()
        applyStateEffectsOneTime()
        applyStateEffectForTime(withDeltaTime: seconds, andCurrentTime: currentTime)
        applyStateEffectOverTime(withDeltaTime: seconds, andCurrentTime: currentTime)
    }
    
    fileprivate func removeAllEffects() {
        damageStateEffects.removeAll()
        throttleStateEffects.removeAll()
        fireStateEffects.removeAll()
        
    }
    
    fileprivate func resetStateEffects() {
        entity.movement.throttle = 0
    }
    
    fileprivate func applyStateEffectsOneTime() {
        for effect in damageStateEffects {
            effect.apply(toEntity: entity)
        }
        damageStateEffects.removeAll()
    }
    
    fileprivate func applyStateEffectForTime(withDeltaTime seconds: TimeInterval, andCurrentTime currentTime: TimeInterval) {
        for effect in throttleStateEffects {
            effect.apply(toEntity: entity)
        }
        throttleStateEffects = throttleStateEffects.filter { !$0.isExpired(currentTime) }
        
        updateVisualEffect(.Throttle, applied: !throttleStateEffects.isEmpty)
    }
    
    fileprivate func applyStateEffectOverTime(withDeltaTime seconds: TimeInterval, andCurrentTime currentTime: TimeInterval) {
        for effect in fireStateEffects {
            effect.apply(toEntity: entity, withDeltaTime: seconds, andCurrentTime: currentTime)
        }
        fireStateEffects = fireStateEffects.filter { !$0.isExpired(currentTime) }
        
        updateVisualEffect(.Fire, applied: !fireStateEffects.isEmpty)
    }
    
    fileprivate func updateVisualEffect(_ effect: VisualStateEffect, applied: Bool) {
        if applied && !appliedVisalEffects.contains(effect) {
            _ = appliedVisalEffects.insert(effect)
            delegate?.addVisualEffect(effect)
        } else if !applied && appliedVisalEffects.contains(effect) {
            appliedVisalEffects.remove(effect)
            delegate?.removeVisualEffect(effect)
        }
    }
}

