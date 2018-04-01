//
//  SpriteComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 18.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

final class UniversalSprite: SKSpriteNode {
    var gameSize: Size {
        set {
            size = CGSize(newValue)
        }
        get {
            return Size(size)
        }
    }
    
    func setVisibleRectOnTexture(_ rect: CGRect, texture: SKTexture) {
        let unitRect = rect.unitRectForSize(size)
        self.texture = SKTexture(rect: unitRect, in: texture)
    }
}
