//#-hidden-code
//
//  Contents.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//
//#-end-hidden-code
/*:
  In this Playground you will learn how to figure out the distance between an enemy and a tower in order to calculate whether the enemy is in the range of a tower.
 
  Your Goal: Write a function that checks if a given enemy is in the range of a given tower.
 
  The Math of Your task:
  Usually, there are many different ways how to accomplish the same calculation with your math. Here, I will describe only one way to do this, feel always free to use a different one.
 
  In order to find out the distance we first of all substract both position vectors of the enemy and the tower:
 
      v₁ = position of the tower
      v₂ = position of the enemy
      Formula = v₂ - v₁
 
  As we are only interested in the length not in the direction, it does not matter if You substract v₂ from v₁ or vice versa.
 
  Next we need to get the length of the direction vector, therefore we sqaure each component of the vector, adding the result together and calculate the square-root:
 
      x = x component of the direction vector
      y = y component of the direction vector
      Formula = √(x * x + y * y)
 
  Finally, we just need to check if the calculated distance is smaller or equal to what is defined as the maximum range of the tower.
  Swifts Math Functions:
 
    √ = sqrt(:_)
    all other operators (like +, -, *, /) are the same in Swift just like for vectors
 
  That’s all.
  Let’s get it done!
 
 */
//#-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(bookauxiliarymodule, hide)
//#-code-completion(keyword, show, var, let)
//#-code-completion(identifier, show, +, -, *, /, sqrt(_:))
//#-code-completion(identifier, hide, PlaygroundViewController, gameController)
//#-code-completion(identifier, hide, isTargetInRange(enemyPosition:towerPosition:maxDistance:))
//#-code-completion(identifier, show, <, >, <=, >=)

import PlaygroundSupport
import simd

//#-end-hidden-code

func isTargetInRange(enemyPosition: Vector, towerPosition: Vector, maxDistance: Scalar) -> Bool {
    //#-editable-code Tap to write Your code
    return false
    //#-end-editable-code
}

//#-hidden-code



let gameController = PlaygroundViewController.shared

gameController.isTargetInRange = isTargetInRange

PlaygroundPage.current.liveView = gameController
validatePlayground("""
````
let direction = enemyPosition - towerPosition
let distance = sqrt(direction.x * direction.x + direction.y * direction.y)
return distance <= maxDistance
````
""")

//#-end-hidden-code
