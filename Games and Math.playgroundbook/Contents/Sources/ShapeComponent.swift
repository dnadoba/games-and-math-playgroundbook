//
//  ShapeComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 13.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import simd

typealias Radius = Scalar

protocol EntityWithShapeComponent {
    var shape: ShapeComponent { get }
}

enum ShapeComponent {
    case rectangle(Size)
    case circle(Radius)
}
extension ShapeComponent{
    var size: Size {
        switch self {
        case .circle(let radius):
            let diameter = radius * 2
            return Size(diameter, diameter)
        case .rectangle(let size):
            return size
        }
    }
}
