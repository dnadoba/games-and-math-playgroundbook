//
//  CameraFocusComponent.swift
//  EntityComponentSystem
//
//  Created by David Nadoba on 21.03.18.
//  Copyright © 2018 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

class CameraFocusComponent<GameType: GameWithNodeSystem, EntityType: EntityWithGame & EntityWithSKCameraNode & EntityWithLayoutableComponents>: BasicComponentWithGame<GameType, EntityType>, LayoutableComponent where GameType == EntityType.GameType {
    
    var mode = SizeScaleMode.contain {
        didSet {
            updateIfNeeded()
        }
    }
    
    private var focusRect: CGRect?
    
    private var cameraNode: SKCameraNode {
        return self.entity.cameraNode
    }
    private var viewSize: Size {
        return game?.nodeSystem.size ?? Size(0, 0)
    }
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        entity.addLayoutableComponent(self)
    }
    
    func layout(_ viewSize: Size) {
        updateIfNeeded()
    }
    
    func focus(rect: CGRect) {
        focusRect = rect
        
        //center camera
        cameraNode.position = rect.mid
        
        // guard for infite scale
        guard rect.width != 0, rect.height != 0 else { return }
        // guard for divison through zero
        guard viewSize.width != 0, viewSize.height != 0 else { return }
        
        //scale camera to contain rect
        let scale = Size(rect.size).scaleFaktorForContent(to: mode, withSize: viewSize)
        
        cameraNode.xScale = CGFloat(scale)
        cameraNode.yScale = CGFloat(scale)
    }
    
    private func updateIfNeeded() {
        guard let focusRect = focusRect else { return }
        focus(rect: focusRect)
    }
}
