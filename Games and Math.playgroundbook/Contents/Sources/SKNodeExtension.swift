//
//  SKNodeExtension.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 17.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

extension SKNode {
    func childNodesWithName(_ name: String) -> [SKNode] {
        var nodes = [SKNode]()
        
        self.enumerateChildNodes(withName: name) { (childNode, _) in
            nodes.append(childNode)
        }
        return nodes
    }
}
