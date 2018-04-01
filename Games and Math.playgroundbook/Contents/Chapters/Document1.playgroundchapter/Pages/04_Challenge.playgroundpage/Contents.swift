//#-hidden-code
//
//  Contents.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//
//#-end-hidden-code
/*:
 This is the complete solution. It uses a methoed defined in `simd`. It is highly optimized and uses special CPU instructions on suported architectures.
 
 Feel free to play around with the new available methods on the `gameController`.
 
 */
//#-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(bookauxiliarymodule, hide)
//#-code-completion(keyword, show, var, let)
//#-code-completion(identifier, show, +, -, *, /, sqrt(_:))
//#-code-completion(identifier, hide, PlaygroundViewController)
//#-code-completion(identifier, hide, isTargetInRange(enemyPosition:towerPosition:maxDistanceSquared:))
//#-code-completion(identifier, show, <, >, <=, >=)

import PlaygroundSupport
import simd

let gameController = PlaygroundViewController.shared
gameController.automaticallyBuildFirstTowers = false
gameController.automaticallyStartFirstWave = false
PlaygroundPage.current.liveView = gameController

//#-end-hidden-code
//#-editable-code
// Solution for the first Challenge
//func isTargetInRange(enemyPosition: Vector, towerPosition: Vector, maxDistance: Scalar) -> Bool {
//    let direction = enemyPosition - towerPosition
//
//    let distance = sqrt(direction.x * direction.x + direction.y * direction.y)
//    return distance <= maxDistance
//}

// Solution for the second Challenge
//func isTargetInRange(enemyPosition: Vector, towerPosition: Vector, maxDistanceSquared: Scalar) -> Bool {
//    let direction = enemyPosition - towerPosition
//
//    let distance = direction.x * direction.x + direction.y * direction.y
//    return distance <= maxDistanceSquared
//}

// Final solution which uses highly optimized simd functions from Apple
func isTargetInRange(enemyPosition: Vector, towerPosition: Vector, maxDistance: Scalar) -> Bool {
    return distance_squared(enemyPosition, towerPosition) <= maxDistance
}

gameController.addMoney(1000)

gameController.buildTowerAtNextFreePlace(type: .bomb)
gameController.buildTowerAtNextFreePlace(type: .fireball)
gameController.buildTowerAtNextFreePlace(type: .ice)
gameController.buildTowerAtNextFreePlace(type: .fire)

gameController.startNextWave()

//#-end-editable-code
//#-hidden-code
gameController.isTargetInRangeSquared = isTargetInRange
validatePlayground()

//#-end-hidden-code
