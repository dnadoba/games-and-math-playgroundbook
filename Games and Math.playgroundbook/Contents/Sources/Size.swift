//
//  Size.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 10.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import CoreGraphics
import simd

enum SizeScaleMode {
    case contain
    case cover
}

struct Size: Equatable {
    fileprivate var value: Vector
    
    var width: Scalar{
        get {
           return value.x
        }
        set {
            value.x = newValue
        }
    }
    
    var height: Scalar{
        get {
            return value.y
        }
        set {
            value.y = newValue
        }
    }
    
    var area: Scalar {
        return value.x * value.y
    }
    
    var aspectRatio: Scalar {
        return value.x / value.y
    }
    
    var min: Scalar {
        return Swift.min(width, height)
    }
    
    var max: Scalar {
        return Swift.max(width, height)
    }
    
    init() {
        self.value = Vector()
    }
    
    init(_ value: Vector) {
        self.value = value
    }
    init(_ width: Scalar, _ height: Scalar) {
        self.value = Vector(width, height)
    }
    
    func scaleFaktorForContent(to scaleMode: SizeScaleMode, withSize contentSize: Size) -> Scalar {
        let scale = self / contentSize
        switch scaleMode {
        case .cover:
            return scale.max
        case .contain:
            return scale.min
        }
    }
    func zoomFaktorForContent(to scaleMode: SizeScaleMode, withSize contentSize: Size) -> Scalar {
        return 1/scaleFaktorForContent(to: scaleMode, withSize: contentSize)
    }
}

extension Vector {
    internal init(_ size: Size){
        self = size.value
    }
}

extension Size {
    init(_ size: CGSize) {
        value = Vector(x: size.width, y: size.height)
    }
    init(_ point: CGPoint) {
        value = Vector(x: point.x, y: point.y)
    }
    init(_ vector: CGVector) {
        value = Vector(x: vector.dx, y: vector.dy)
    }
}



func == (lhs: Size, rhs: Size) -> Bool{
    return lhs.value == rhs.value
}

// Arithmetic with Scalar


func + (lhs: Size, rhs: Scalar) -> Size{
    return Size(lhs.value + Vector(rhs))
}



func - (lhs: Size, rhs: Scalar) -> Size{
    return Size(lhs.value - Vector(rhs))
}



func * (lhs: Size, rhs: Scalar) -> Size{
    return Size(lhs.value * rhs)
}



func / (lhs: Size, rhs: Scalar) -> Size{
    return Size(lhs.value / Vector(rhs))
}

// Arithmetic with Size



func + (lhs: Size, rhs: Size) -> Size {
    return Size(lhs.value + rhs.value)
}



func - (lhs: Size, rhs: Size) -> Size {
    return Size(lhs.value - rhs.value)
}



func * (lhs: Size, rhs: Size) -> Size {
    return Size(lhs.value * rhs.value)
}



func / (lhs: Size, rhs: Size) -> Size {
    return Size(lhs.value / rhs.value)
}

// Arithmetic with Vector



func + (lhs: Size, rhs: Vector) -> Vector {
    return lhs.value + rhs
}



func + (lhs: Vector, rhs: Size) -> Vector {
    return lhs + rhs.value
}



func - (lhs: Size, rhs: Vector) -> Vector {
    return lhs.value - rhs
}


func - (lhs: Vector, rhs: Size) -> Vector {
    return lhs - rhs.value
}



func * (lhs: Size, rhs: Vector) -> Vector {
    return lhs.value * rhs
}



func / (lhs: Size, rhs: Vector) -> Vector {
    return lhs.value / rhs
}

// inout Arithmetic with Scalar


func += (lhs: inout Size, rhs: Scalar) {
    lhs.value += Vector(rhs)
}


func -= (lhs: inout Size, rhs: Scalar) {
    lhs.value -= Vector(rhs)
}


func *= (lhs: inout Size, rhs: Scalar) {
    lhs.value *= rhs
}


func /= (lhs: inout Size, rhs: Scalar) {
    lhs.value /= Vector(rhs)
}

// inout Arithmetic with Size


func += (lhs: inout Size, rhs: Size) {
    lhs.value += rhs.value
}


func -= (lhs: inout Size, rhs: Size) {
    lhs.value -= rhs.value
}


func *= (lhs: inout Size, rhs: Size){
    lhs.value *= rhs.value
}


func /= (lhs: inout Size, rhs: Size) {
    lhs.value /= rhs.value
}
