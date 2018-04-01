//
//  Way.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 17.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import simd

enum WayOffsetDirection {
    case left
    case right
    
    func rotate(_ vector: Vector) -> Vector {
        switch self{
        case .left:
            return vector.rotateCounterClockwise
        case .right:
            return vector.rotateClockwise
        }
    }
    
    func offset(_ direction: Vector, offsetLength: Scalar) -> Vector {
        return rotate(direction) * offsetLength
    }
}

struct Way {
    let origin: Vector
    let path: VectorPath
    init(origin: Vector, path: VectorPath) {
        self.origin = origin
        self.path = path
    }
    
    func wayByOffset(_ offsetLength: Scalar, inDirection offsetDirection: WayOffsetDirection) -> Way {
        guard path.count > 0 else {
            return Way(origin: origin, path: path)
        }
        
        var waypoints = [Vector]()
        var lastWaypoint = origin
        
        var generator = path.makeIterator()
        
        var lastSegment: VectorPathSegment?
        
        for _ in path.startIndex...path.endIndex {
            let segment = generator.next() ?? path.last!
            var waypoint = lastWaypoint + offsetDirection.offset(segment.direction, offsetLength: offsetLength)
            if let lastSegment = lastSegment {
                waypoint += offsetDirection.offset(lastSegment.direction, offsetLength: offsetLength)
            }
            waypoints.append(waypoint)
            lastWaypoint = lastWaypoint + segment.direction * segment.length
            lastSegment = segment
        }
        
        return Way(origin: waypoints.first!, path: VectorPath(fromWaypoints: waypoints))
    }
}

extension MoveAlongPathComponent {
    func moveAlongWay(_ way: Way) {
        entity.position = way.origin
        moveAlongPath(way.path)
    }
}
