//
//  CoreGraphics.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 04.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import simd
import CoreGraphics

extension CGPoint{
    init(_ vector: Vector){
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }
    
    init(_ size: Size) {
        self.init(x: CGFloat(size.width), y: CGFloat(size.height))
    }
    
    var vector: Vector {
        return Vector(self)
    }
}

extension CGSize {
    init(_ size: Size) {
        self.init(width: CGFloat(size.width), height: CGFloat(size.height))
    }
}

extension CGRect {
    init(_ rect: Rectangle) {
        self.init(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height)
    }
}

extension CGVector {
    init(_ x: Scalar, _ y: Scalar) {
        self = CGVector(dx: CGFloat(x), dy: CGFloat(y))
    }
    init(_ size: Size){
        self = CGVector(size.width, size.height)
    }
}
