//
//  UniversalTexture.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 18.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

final class UniversalTexture: SKTexture {
    var gameSize = Size()
    
    func textureInRect(_ rect: CGRect) -> SKTexture {
        let unitRect = rect.unitRectForSize(CGSize(gameSize))
        return SKTexture(rect: unitRect, in: self)
    }
}
