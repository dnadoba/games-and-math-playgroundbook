//
//  TowerBuildOption.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 26.07.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit


class TowerBuildOption<GameType: GameWithTimerSystem & GameWithNodeSystem & GameWithTargetableSystem & GameWithInteractionSystem>: BasicEntityWithGame<GameType>, EntityWithInteraction, MenuOption {
    
    let interaction = InteractionComponent<GameType, TowerBuildOption<GameType>>()
    
    let towerType: TowerType
    
    init(towerType: TowerType) {
        self.towerType = towerType
        switch towerType{
        case .fire:
            texture = SKTexture(imageNamed: "FireTowerBuildOption")
        case .ice:
            texture = SKTexture(imageNamed: "IceTowerBuildOption")
        case .fireball:
            texture = SKTexture(imageNamed: "FireballTowerBuildOption")
        case .bomb:
            texture = SKTexture(imageNamed: "BombTowerBuildOption")
        }
        super.init()
    }
    
    fileprivate let sprite = UniversalSprite()
    fileprivate let texture: SKTexture
    
    override func initComponents() {
        super.initComponents()
        rootNode.relatedToEntity = false
        
        interaction.initComponent(withEntity: self)
        interaction.shape = .rectangle(Size(150, 150))
        
        sprite.gameSize = Size(150, 150)
        sprite.texture = texture
        addChild(sprite)
        
        rootNode.zIndexOffset = 10000
        
        #if os(tvOS)
            
        interaction.focusUpdate.on(self) { [unowned self] focusEvent in
            self.didUpdateFocus(with: focusEvent)
        }
        #endif
    }
    
    fileprivate let showAnimationDuration: TimeInterval = 0.2
    
    func show() {
        sprite.removeAction(forKey: "visibility")
        rootNode.removeFromScene()
        rootNode.addToScene()
        
        sprite.setScale(0.5)
        sprite.alpha = 1
        
        let scaleAction = SKAction.scale(to: 1, duration: showAnimationDuration)
        scaleAction.timingMode = .easeOut
        sprite.run(scaleAction, withKey: "visibility")
    }
    
    fileprivate let hideAnimationDuration: TimeInterval = 0.2
    
    func hide() {
        sprite.removeAction(forKey: "visibility")
        let scaleAction = SKAction.scale(to: 0.5, duration: hideAnimationDuration)
        scaleAction.timingMode = .easeOut
        
        let fadeOutAction = SKAction.fadeOut(withDuration: hideAnimationDuration)
        
        let hideAction = SKAction.group([
                scaleAction,
                fadeOutAction,
            ])
        hideAction.timingMode = .easeInEaseOut

        let removeAction = SKAction.run {
            self.rootNode.removeFromScene()
        }
        
        sprite.run(SKAction.sequence([
                hideAction,
                removeAction,
            ]), withKey: "visibility")
    }
    
    #if os(tvOS)
    func didUpdateFocus(with focusEvent: FocusUpdateEvent) {
        var duration: TimeInterval = focusEvent.isFocused ? 0.1 : 0.2
        let scale: CGFloat = focusEvent.isFocused ? 1.2 : 1.0
        if sprite.action(forKey: "visibility") != nil {
            guard focusEvent.isFocused else {
                return
            }
            duration = showAnimationDuration
        }
        sprite.removeAction(forKey: "visibility")
        sprite.removeAction(forKey: "focus")
        
        
        let scaleAction = SKAction.scale(to: scale, duration: duration)
        scaleAction.timingMode = focusEvent.isFocused ? .easeOut : .easeInEaseOut
        sprite.run(scaleAction, withKey: "focus")
    }
    #endif
}
