//
//  Tower.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 29.01.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit
#if os(iOS) || os(tvOS)
import UIKit
#endif

public enum TowerType: Int {
    case fire = 0
    case ice
    case bomb
    case fireball
    
    static var count = 4
    
    func makeAndAddToGame<GameType: GameWithTimerSystem & GameWithNodeSystem & GameWithTargetableSystem & GameWithInteractionSystem & GameWithSoundSystem>(_ game: GameType) -> Tower<GameType> {
        var tower: Tower<GameType>!
        switch self {
        case .fire: tower = FireTower<GameType>()
        case .ice: tower = IceTower<GameType>()
        case .bomb: tower = BombTower<GameType>()
        case .fireball: tower = FireballTower<GameType>()
        }
        game.addEntityWithGame(tower)
        return tower
    }
    
    var info: TowerInfo {
        switch self {
        case .fire: return TowerInfo(name: "Fireflamer", price: 150)
        case .ice: return TowerInfo(name: "Frozer", price: 125)
        case .bomb: return TowerInfo(name: "Bomber", price: 200)
        case .fireball: return TowerInfo(name: "Fireball Tower", price: 100)
        }
    }
}

struct TowerInfo {
    var name: String
    var price: Int
}

class Tower<GameType: GameWithTimerSystem & GameWithNodeSystem & GameWithTargetableSystem & GameWithInteractionSystem>: BasicEntityWithGame<GameType>, EntityWithInteraction {
    
    var size = Size(0, 0) {
        didSet {
            interaction.shape = .rectangle(size)
            sprite.gameSize = size
            #if os(tvOS)
                //focus.size = size
            #endif
        }
    }
    #if os(iOS) || os(tvOS)
    var views: [UIView] = []
    #endif
    let interaction = InteractionComponent<GameType, Tower<GameType>>()

    fileprivate let sprite = UniversalSprite()
    
    var texture: SKTexture? {
        set {
            sprite.texture = newValue
            if let newTexture = newValue {
                size = Size(newTexture.size())
            }
        }
        get {
            return sprite.texture
        }
    }
    
    override func initComponents() {
        super.initComponents()
        interaction.initComponent(withEntity: self)
        
        addChild(sprite)

        #if os(tvOS)
            
            interaction.focusUpdate.on(self) { [unowned self] focusEvent in
                self.didUpdateFocus(with: focusEvent)
            }
        #endif
    }
    
    #if os(tvOS)
    func didUpdateFocus(with focusEvent: FocusUpdateEvent) {
        let scale: CGFloat = focusEvent.isFocused ? 1.2 : 1.0
        let duration: TimeInterval = focusEvent.isFocused ? 0.1 : 0.2
        sprite.removeAction(forKey: "focus")
        let scaleAction = SKAction.scale(to: scale, duration: duration)
        scaleAction.timingMode = .easeInEaseOut
        sprite.run(scaleAction, withKey: "focus")
    }
    #endif
}
