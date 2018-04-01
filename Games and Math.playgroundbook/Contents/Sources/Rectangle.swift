//
//  Rectangle.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 10.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import CoreGraphics
import simd

struct Rectangle {
    var center: Vector
    var size: Size
    
    var halfSize: Size { return size / 2 }
    
    init() {
        self.center = Vector()
        self.size = Size()
    }
    
    init(center: Vector, size: Size) {
        self.center = center
        self.size = size
    }
    
    init(x: Scalar, y: Scalar, width: Scalar, height: Scalar){
        center = Vector(x, y)
        size = Size(width, height)
    }
    
    var width: Scalar{
        get { return size.width }
        set { size.width = newValue }
    }
    var height: Scalar{
        get { return size.height }
        set { size.height = newValue }
    }
    
    var halfWidth: Scalar { return size.width/2}
    var halfHeight: Scalar { return size.height/2 }
    
    var x: Scalar{
        get { return center.x }
        set { center.x = newValue }
    }
    var y: Scalar{
        get { return center.y }
        set { center.y = newValue }
    }
    
    var minX: Scalar { return center.x - halfWidth }
    var minY: Scalar { return center.y - halfHeight }
    
    var midX: Scalar { return center.x }
    var midY: Scalar { return center.y }
    
    var maxX: Scalar { return center.x + halfWidth }
    var maxY: Scalar { return center.y + halfHeight }
    
    var topY: Scalar { return center.y + halfHeight }
    var rightX: Scalar { return center.x + halfWidth }
    var bottomY: Scalar { return center.y - halfHeight }
    var leftX: Scalar { return center.x - halfWidth }
    
    var topLeft: Vector { return Vector(leftX, topY) }
    var topRight: Vector { return center + halfSize }
    var bottomRight: Vector { return Vector(rightX, bottomY) }
    var bootomLeft: Vector { return center - halfSize }
    
    mutating func inset(by size: Size) {
        self.size -= size
    }
    
    func insetted(by size: Size) -> Rectangle {
        var copy = self
        copy.inset(by: size)
        return copy
    }
    
    func intersect(with point: Vector) -> Bool{
        return point.x > minX &&
                point.x < maxX &&
                point.y > minY &&
                point.y < maxY
    }
}

extension Rectangle {
    init(_ rect: CGRect) {
        self.init(center: Vector(rect.origin), size: Size(rect.size))
    }
}
