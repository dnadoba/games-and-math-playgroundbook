//
//  SIMD.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 04.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import simd
import CoreGraphics

extension int2: Comparable {
    init(_ point: CGPoint){
        self.init(Int32(point.x), Int32(point.y))
    }
    init(_ x: Int, _ y: Int) {
        self.init(Int32(x), Int32(y))
    }
}

public func < (left: int2, right: int2) -> Bool{
    return left.x < right.x && left.y < right.y
}

extension Vector: Comparable {
    @inline(__always)
    init(_ x: Int, _ y: Int) {
        self.init(Vector.Element(x), Vector.Element(y))
    }
    @inline(__always)
    init(_ vector: CGPoint){
        self.init(Vector.Element(vector.x), Vector.Element(vector.y))
    }
    @inline(__always)
    init(x: CGFloat, y: CGFloat){
        self.init(Vector.Element(x), Vector.Element(y))
    }
    
    @inline(__always)
    mutating func set(_ x: Vector.Element, _ y: Vector.Element) {
        self.x = x
        self.y = y
    }
    /**
        normlize this vector
     */
    @inline(__always)
    mutating func normalize(){
        self = simd.normalize(self)
    }
    /**
        Unit vector pointing in the same direction as x.
     */
    var normalized: Vector {
        return simd.normalize(self)
    }
    
    //angle in radians from (0,0)
    var angle: Vector.Element {
        return atan2(self.y, self.x)
    }
    
    
    @inline(__always)
    func directionTo(_ vector: Vector) -> Vector {
        return vector - self
    }
    
    
    @inline(__always)
    func distanceTo(_ to: Vector) -> Vector.Element {
        return simd.distance(self, to)
    }
    
    @inline(__always)
    func distanceSquaredTo(_ to: Vector) -> Vector.Element {
        return simd.distance_squared(self, to)
    }
    
    
    @inline(__always)
    func dot(_ with: Vector) -> Vector.Element {
        return simd.dot(self, with)
    }
    
    var length: Vector.Element {
        return simd.length(self)
    }
    //rotate left
    
    var rotateCounterClockwise: Vector {
        return Vector(y, -x)
    }
    
    //rotate right
    var rotateClockwise: Vector {
        return Vector(-y, x)
    }
    
    
    @inline(__always)
    func rotate(_ angle: Radian) -> Vector {
        let cs = cos(angle)
        let sn = sin(angle)
        
        return Vector(
            x * cs - y * sn,
            x * sn + y * cs
        )
    }
}

public func < (left: Vector, right: Vector) -> Bool{
    return left.x < right.x && left.y < right.y
}
