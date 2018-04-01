//
//  Loader.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 16.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

protocol LevelLoader: class {
    func loadLevel(_ sceneModel: SKNode, withName: String) -> Bool
}
