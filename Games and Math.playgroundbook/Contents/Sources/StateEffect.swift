//
//  StateEffect.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 02.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

enum StateEffect {
    case damage(DamageStateEffect)
    case throttle(ThrottleStateEffect)
    //case Freeze(ThrottleStateEffect)
    case fire(FireStateEffect)
}

protocol StateEffectWithAttribute {
    var attribute: StateAttribute { get }
}

protocol StateEffectWithDuration: StateEffectWithAttribute {
    var duration: TimeInterval { get }
}

protocol StateEffectWithAmount: StateEffectWithAttribute {
    var amount: Scalar { get }
}

struct DamageStateEffect: StateEffectWithAmount {
    let attribute = StateAttribute.health
    let amount: Scalar
    init(_ amount: Scalar) {
        self.amount = amount
    }
}

func +(lhs: DamageStateEffect, rhs: DamageStateEffect) -> Double {
    return lhs.amount + rhs.amount
}

struct ThrottleStateEffect: StateEffectWithDuration, StateEffectWithAmount {
    let attribute = StateAttribute.throttle
    let amount: Scalar
    let duration: TimeInterval
    init(_ amount: Scalar, duration: Scalar) {
        self.amount = -amount
        self.duration = duration
    }
}
func +(lhs: ThrottleStateEffect, rhs: ThrottleStateEffect) -> Double {
    return lhs.amount + rhs.amount
}

struct FreezeStateEffect: StateEffectWithDuration {
    let attribute = StateAttribute.throttle
    let duration: TimeInterval
}

struct FireStateEffect: StateEffectWithAmount, StateEffectWithDuration {
    let attribute = StateAttribute.health
    let amount: Scalar
    let duration: TimeInterval
    init(_ amount: Scalar, duration: Scalar) {
        self.amount = amount
        self.duration = duration
    }
}

