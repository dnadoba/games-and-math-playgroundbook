//#-hidden-code
//
//  Contents.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//
//#-end-hidden-code
/*:
 Now you will learn how to calculate the range between tower and enemy in a more efficient way, without taking the square-root, as the square-root function is a time-consuming, expensive function compared to operations like subtraction, multiplication or simple comparison.
 
 We can eliminate the square-root call in our function by squaring each side of our equation:
 
     x = x component of the direction vector
     y = y component of the direction vector
     d = max distance
 
     √(x * x + y * y) <= d | ²
     √(x * x + y * y)² <= d² | (√)² dissolves
     x * x + y * y <= d²
 
 As You can see, the signature of our function has changed slightly. Your now get the square of the distance. Everything else remains as before.
 This means that now `d² = maxDistanceSquared` and we do not need to square the max distance.
 
 */
//#-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(bookauxiliarymodule, hide)
//#-code-completion(keyword, show, var, let)
//#-code-completion(identifier, show, +, -, *, /, sqrt(_:))
//#-code-completion(identifier, hide, PlaygroundViewController, gameController)
//#-code-completion(identifier, hide, isTargetInRange(enemyPosition:towerPosition:maxDistanceSquared:))
//#-code-completion(identifier, show, <, >, <=, >=)

import PlaygroundSupport
import simd

//#-end-hidden-code

func isTargetInRange(enemyPosition: Vector, towerPosition: Vector, maxDistanceSquared: Scalar) -> Bool {
    //#-editable-code Tap to write Your code
    let direction = enemyPosition - towerPosition
    return false
    //#-end-editable-code
}

//#-hidden-code

let gameController = PlaygroundViewController.shared

gameController.isTargetInRangeSquared = isTargetInRange

PlaygroundPage.current.liveView = gameController
validatePlayground("""
````
let direction = enemyPosition - towerPosition
let distance = direction.x * direction.x + direction.y * direction.y
return distance <= maxDistanceSquared
````
""")

//#-end-hidden-code
