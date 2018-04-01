//
//  TowerBuildPlace.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 17.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

var towerBuildCount = 0
var towerBuildPlaceCount = 0

final class TowerBuildPlace<GameType: GameWithTimerSystem & GameWithNodeSystem & GameWithTargetableSystem & GameWithMoneyManager & GameWithInteractionSystem & GameWithSoundSystem>: Tower<GameType> {
    
    let menu = MenuComponent<GameType, TowerBuildPlace<GameType>, TowerBuildOption<GameType>>()
    fileprivate let towerInfo = TowerInfoEntity<GameType>()
    var shouldShowTowerInfo = false
    
    override func initComponents() {
        super.initComponents()
        
        texture = SKTexture(imageNamed: "TowerBuildPlace")
        size = Size(128, 107)
        
        towerBuildPlaceCount += 1
        
        menu.initComponent(withEntity: self)
        
        
        var isMenuInitialized = false
        interaction.tap.on(self) { [unowned self] _ in
            if !isMenuInitialized {
                self.initTowerBuildMenu()
                isMenuInitialized = true
            }
            self.menu.show()
        }
    }
    
    override func added(to game: GameType) {
        super.added(to: game)
        game.addEntityWithGame(towerInfo)
    }
    
    override func removed(from game: GameType) {
        super.removed(from: game)
        towerInfo.removeFromGame()
    }
    
    
    func initTowerBuildMenu() {
        var offset = Vector(90, 90)
        
        menu.options = (0..<4).map { index -> TowerBuildOption<GameType> in
            offset = offset.rotateClockwise
            
            let towerId = index % TowerType.count
            let towerType = TowerType(rawValue: towerId)!
            
            let towerBuildOption = TowerBuildOption<GameType>(towerType: towerType)
            towerBuildOption.position = self.position + offset
            return towerBuildOption
        }
        
        
        menu.validInteractableTapTargets = [self.interactable]
        
        var selectedTowerType: TowerType?
        
        menu.visibilityChange.on(self) { visible in
            self.interaction.isInteractable = !visible
            selectedTowerType = nil
            self.towerInfo.hide()
        }
        
        menu.selected.on(self) { [weak menu, unowned self] option in
            let towerType = option.towerType
            if !self.shouldShowTowerInfo || selectedTowerType == towerType {
                self.buildTower(type: towerType)
                menu?.hide()
            } else {
                selectedTowerType = towerType
                self.showInfo(of: towerType)
            }
        }
    }
    
    func showInfo(of towerType: TowerType) {
        towerInfo.position = position + Vector(450, 0)
        towerInfo.show(tower: towerType.info)
    }
    
    func buildTower(type towerType: TowerType) {
        guard let game = game, game.moneyManager.buyItem(for: 100) else {
            return
        }
        
        
        let tower = towerType.makeAndAddToGame(game)
        towerBuildCount += 1
        
        tower.position = position
        self.removeFromGame()
        
    }
}
