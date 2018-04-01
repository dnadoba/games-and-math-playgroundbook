//
//  EntitySpawnSquad.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 25.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

private struct SpawnPointPosition {
    let prototype: String
    let position: Vector
    init?(fromNode node: SKNode) {
        guard let name = node.name else {
            return nil
        }
        self.prototype = name
        self.position = Vector(node.position)
    }
    
    func wayIndexFor(_ minWayPosition: Scalar, waySize: Scalar) -> Int {
        let relativeWayPosition = position.y - minWayPosition
        let wayIndex = Int(relativeWayPosition/waySize)
        return wayIndex
    }
    
    func distanceTo(_ previous: SpawnPointPosition) -> Scalar {
        return abs(previous.position.x - self.position.x)
    }
}

extension SpawnPointPosition: Comparable {}

private func < (lhs: SpawnPointPosition, rhs: SpawnPointPosition) -> Bool{
    return lhs.position.x < rhs.position.x
}

private func > (lhs: SpawnPointPosition, rhs: SpawnPointPosition) -> Bool{
    return lhs.position.x > rhs.position.x
}

private func == (lhs: SpawnPointPosition, rhs: SpawnPointPosition) -> Bool{
    return lhs.position.x == rhs.position.x
}

enum EntitySpawnDelay {
    case immediately
    case distanceToPrevious(Scalar)
    case WaitDuration(Scalar)
    
    
    func waitDuration(_ speedOfPreviousEntity: Scalar?) -> Scalar {
        switch self {
        case .immediately:
            return 0
        case .WaitDuration(let duration):
            return duration
        case .distanceToPrevious(let distance):
            guard let speed = speedOfPreviousEntity else {
                return 0
            }
            return distance / speed
        }
    }
}

struct EntitySpawnInfo {
    let prototype: String
    let wayIndex: Int
    let spawnDelay: EntitySpawnDelay
    init(_ prototype: String, wayIndex: Int, distanceToPrevious: Scalar) {
        self.prototype = prototype
        self.wayIndex = wayIndex
        self.spawnDelay = .distanceToPrevious(distanceToPrevious)
    }
    
    init(_ spawnInfo: EntitySpawnInfo, distanceToPrevious: Scalar) {
        self.prototype = spawnInfo.prototype
        self.wayIndex = spawnInfo.wayIndex
        self.spawnDelay = .distanceToPrevious(distanceToPrevious)
    }
}

struct EntitySpawnSquad {
    
    let wayCount = 3
    
    var spawnInfos: [EntitySpawnInfo] = []
    
    var startDelay: EntitySpawnDelay = .immediately
    
    init(fileNamed: String, startDelay: EntitySpawnDelay) {
        self.init(fileNamed: fileNamed)
        self.startDelay = startDelay
    }
    
    init(fileNamed: String) {
        
        let spawnPoints = loadSpawnPoints(fileNamed).sorted(by: >)
        
        guard spawnPoints.count > 0 else {
            fatalError("EntitySpawnSquad with file name \(fileNamed) has no spawn points")
        }
        
        let minWayPosition = spawnPoints.reduce(Scalar.infinity) { min($0, $1.position.y) }
        let maxWayPosition = spawnPoints.reduce(-Scalar.infinity) { max($0, $1.position.y) }
        
        let laneSize = (maxWayPosition - minWayPosition)
        
        let waySize = laneSize / Scalar(wayCount)
        
        var previousSpawnPoint = spawnPoints.first!
        
        spawnInfos = spawnPoints.map { spawnPoint -> EntitySpawnInfo in
            let wayIndex = min(spawnPoint.wayIndexFor(minWayPosition, waySize: waySize), wayCount - 1)
            let distance = spawnPoint.distanceTo(previousSpawnPoint)
            previousSpawnPoint = spawnPoint
            return EntitySpawnInfo(spawnPoint.prototype, wayIndex: wayIndex, distanceToPrevious: distance)
        }
    }
    
    fileprivate func loadSpawnPoints(_ fileNamed: String) -> [SpawnPointPosition] {
        guard let rootNode = SKNode(fileNamed: fileNamed) else {
            fatalError("could not find EntitySpawnSquad with file name: \(fileNamed)")
        }
        let spawnPoints = rootNode.children.flatMap {
            return SpawnPointPosition(fromNode: $0)
        }
        
        if spawnPoints.count != rootNode.children.count {
            print("some children from EntitySpawnSquad in file \(fileNamed) are not used as spawn points")
        }
        return spawnPoints
    }
    
}
