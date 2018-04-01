//
//  VectorPath.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 16.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import simd


struct VectorPathSegment {
    let direction: Vector
    let length: Scalar
    init(start: Vector, end: Vector) {
        self.init(vector: end - start)
    }
    init(vector: Vector) {
        direction = normalize(vector)
        length = simd.length(vector)
    }
}

struct VectorPath: Collection {
    typealias Index = Int
    fileprivate let path: [VectorPathSegment]
    
    lazy var length: Scalar = {
        return self.path.reduce(0) { $0 + $1.length }
    }()
    
    var count: Int {
        return path.count
    }
    var startIndex: Int {
        return path.startIndex
    }
    var endIndex: Int {
        return path.endIndex
    }
    
    var last: VectorPathSegment? {
        return path.last
    }
    
    init(path: [VectorPathSegment]) {
        self.path = path
    }
    
    init(fromWaypoints: [Vector]) {
        var waypoints = fromWaypoints
        guard waypoints.count >= 2 else {
            self.init(path: [])
            return
        }
        
        var segments = [VectorPathSegment]()
        
        var lastWaypoint = waypoints.removeFirst()
        for nextWaypoint in waypoints {
            let segment = VectorPathSegment(start: lastWaypoint, end: nextWaypoint)
            segments.append(segment)
            lastWaypoint = nextWaypoint
        }
        
        self.init(path: segments)
    }
    
    func index(after i: Int) -> Int {
        return i + 1
    }
    
    subscript(position: VectorPathPosition) -> VectorPathSegment {
        return path[position.segmentIndex]
    }
    subscript(index: Index) -> VectorPathSegment {
        return path[index]
    }
}

struct VectorPathPosition: CustomDebugStringConvertible {
    //current position
    var position = Vector()
    //current direction
    var direction = Vector(1, 0)
    
    //index of the current path segment on the vector path
    var segmentIndex = 0
    //moved distance on the current path segment
    var segmentLengthMoved = Scalar(0)
    //total moved distance
    var distanceMoved = Scalar(0)
    
    init(){}
    
    init(origin: Vector) {
        position = origin
    }
    
    mutating func moveAlongPath(_ path: VectorPath, length: Scalar) {
        var remainingLength = length
        while remainingLength > 0 && !didReachEnd(path) {
            let segment = path[self]
            let segmentLengthRemaining = segment.length - segmentLengthMoved
            
            let lengthToMove = min(remainingLength, segmentLengthRemaining)
            
            position += segment.direction * lengthToMove
            direction = segment.direction
            segmentLengthMoved += lengthToMove
            distanceMoved += lengthToMove
            
            remainingLength -= lengthToMove
            
            if segmentLengthMoved >= segment.length {
                nextSegment()
            }
        }
    }
    
    func didReachEnd(_ path: VectorPath) -> Bool{
        return self.segmentIndex >= path.count
    }
    
    mutating fileprivate func nextSegment() {
        segmentIndex += 1
        segmentLengthMoved = 0
    }
    
    var debugDescription: String {
        return position.debugDescription
    }
}
