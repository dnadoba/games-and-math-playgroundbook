//
//  Circle.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 24.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

struct Circle {
    var center: Vector
    var radius: Scalar
    init(center: Vector, atRadius radius: Scalar) {
        self.center = center
        self.radius = radius
    }
    func intersect(with point: Vector) -> Bool{
        let distance = point.distanceTo(center)
        return distance < radius
    }
}
