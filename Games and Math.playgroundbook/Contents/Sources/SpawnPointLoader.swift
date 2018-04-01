//
//  WayLoader.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 16.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


protocol GameWithSpawnPoints: GameWithEnemyPrototypeList, GameWithTargetableSystem, GameWithEnemyManager {
    var spawnPoints: [String: SpawnPoint<Self>] { get set }
}

private struct LaneModel {
    var name = ""
    var way: Way
    init?(name: String?, way: Way?) {
        guard let name = name,
            let way = way else {
                
            return nil
        }
        self.name = name
        self.way = way
    }
}

final class SpawnPointLoader<GameType: GameWithSpawnSystem>: LevelLoader {
    unowned var game: GameType
    
    init(game: GameType) { self.game = game }
    func loadLevel(_ sceneModel: SKNode, withName levelName: String) -> Bool {
        
        let lanes = sceneModel.childNodesWithName("lane[0-9]").sorted { $0.name < $1.name }
            .flatMap { (wayNode: SKNode) -> LaneModel? in
                return LaneModel(
                    name: wayNode.name,
                    way: loadWay(sceneModel, waypointNodes: wayNode)
                )
            }
        
        
        let laneWaves = loadWaves(levelName, forLanes: lanes)
        
        let spawnPoints = zip(lanes, laneWaves).flatMap { loadSpawnPoint($0.0, waves: $0.1) }
        
        
        
        spawnPoints.forEach(game.addEntityWithGame)
        
        
        return true
    }
    
    fileprivate func loadWaves(_ levelName: String, forLanes laneModels: [LaneModel]) -> [[WavePrototype]] {
        let lanePrototypeList = PrototypeList<LanePrototype>(fileNamed: levelName + "Waves")
        
        return laneModels.map { (laneModel: LaneModel) -> [WavePrototype] in
            guard let wavePrototypeList = lanePrototypeList.prototypeByName(laneModel.name)?.wavePrototypeList else {
                fatalError("Could not find a lane prototype by name \(laneModel.name) in \(lanePrototypeList)")
            }
            
            return wavePrototypeList.list()
        }
    }
    
    fileprivate func loadSpawnPoint(_ model: LaneModel, waves: [WavePrototype]) -> SpawnPoint<GameType> {
        let wayOffset = Scalar(100/3)
        let way = model.way
        let spawnPoint = SpawnPoint<GameType>(named: model.name)
        spawnPoint.position = way.origin
        
        spawnPoint.spawnQueue.ways = [
            way.wayByOffset(wayOffset, inDirection: .left),
            way,
            way.wayByOffset(wayOffset, inDirection: .right),
        ]
        
        spawnPoint.waveQueue.waves = waves
        
        return spawnPoint
    }
    
    fileprivate func loadWay(_ sceneModel: SKNode, waypointNodes: SKNode) -> Way? {
        
        let waypoints = waypointNodes.children.sorted { Int($0.name!)! < Int($1.name!)! }
            .map { (waypointNode: SKNode) -> Vector in
                let position = waypointNode.position
                return Vector(position)
            }
        
        guard waypoints.count >= 2 else {
            return nil
        }
        
        let path = VectorPath(fromWaypoints: waypoints)
        return Way(origin: waypoints.first!, path: path)
    }
}
