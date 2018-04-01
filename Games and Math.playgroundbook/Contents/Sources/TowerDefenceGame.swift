//
//  TowerDefenceGame.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 02.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit



protocol TowerDefenceGameDelegate: class {}

final class TowerDefenceGame: BasicGame, GameWithTargetableSystem, GameWithEnemyPrototypeList, GameWithSpawnPoints, GameWithSpawnSystem, GameWithEnemyManager, GameWithMoneyManager, GameWithLifeManager, GameWithInteractionSystem, GameWithSoundSystem {
    
    weak var delegate: TowerDefenceGameDelegate?
    
    let stateMachine = TowerDefenceGameStateMachine<TowerDefenceGame>()
    
    let interactionSystem = InteractionSystem<TowerDefenceGame>()
    let targetableSystem = TargetableSystem<TowerDefenceGame>()
    let spawnSystem = SpawnSystem<TowerDefenceGame>()
    let soundSystem = SoundSystem<TowerDefenceGame>()
    let fireworkSystem = FireworkSystem<TowerDefenceGame>()
    
    
    let enemyPrototypeList = PrototypeList<EnemyPrototype>(fileNamed: "EnemyPrototype")
    
    var spawnPoints: [String: SpawnPoint<TowerDefenceGame>] = [:]
    
    let enemyManager = EnemyManager<TowerDefenceGame>()
    let lifeManager = LifeManager<TowerDefenceGame>()
    let moneyManager = MoneyManager<TowerDefenceGame>()
    #if os(macOS)
    let viewSizeManager = ViewSizeManager<TowerDefenceGame>()
    #endif
    

    var view: SKView? {
        return nodeSystem.scene.view
    }

    
    override func initSystems() {
        super.initSystems()
        addSystemWithGame(interactionSystem)
        addSystemWithGame(targetableSystem)
        addSystemWithGame(spawnSystem)
        addSystemWithGame(soundSystem)
        addSystemWithGame(fireworkSystem)
        
        scene.focusDelegate = interactionSystem
    }
    
    override func initEntities() {
        super.initEntities()
        addEntityWithGame(enemyManager)
        addEntityWithGame(lifeManager)
        addEntityWithGame(moneyManager)
        #if os(macOS)
        addEntityWithGame(viewSizeManager)
        #endif
        
        enemyManager.escapeDelegate = lifeManager
        enemyManager.rewardDelegate = moneyManager
        
        addEntityWithGame(stateMachine)
    }
    
    override func initLevelLoaders() {
        super.initLevelLoaders()
        self.addLevelLoader(BackgroundColorLoader(game: self))
        self.addLevelLoader(ContentSizeLoader(game: self))
        self.addLevelLoader(ContentInsetLoader(game: self))
        self.addLevelLoader(MapLoader(game: self))
        self.addLevelLoader(SpawnPointLoader(game: self))
        self.addLevelLoader(TowerBuildPlaceLoader(game: self))
    }
    
    func getTowerBuildPlaces() -> [TowerBuildPlace<TowerDefenceGame>] {
        return entities(of: TowerBuildPlace<TowerDefenceGame>.self)
    }
    
    func shoudlShowTowerInfo(show: Bool) {
        getTowerBuildPlaces().forEach { (towerBuildPlace) in
            towerBuildPlace.shouldShowTowerInfo = show
        }
    }
    
    override func didLoadLevel() {
        super.didLoadLevel()
        #if os(iOS) || os(tvOS)
        camera.scrollView.zoomOut()
        #endif
        /*
        let towerBuildPlaces = getTowerBuildPlaces()
        
        let middleIndex = Int(Scalar(towerBuildPlaces.count) / 2)
        
        let towerBuildPlace = towerBuildPlaces[safe: middleIndex]
        
        towerBuildPlace?.showTowerBuildOptions()
        */
        
        
        stateMachine.didChangeState.on(self) { [unowned self] (gameState) in
            switch gameState.currentState {
            case .won:
                self.makeFirework()
                self.soundSystem.playSound(fileNamed: "won.m4a")
            default: break
            }
        }
    }
    
    override func didMoveToView(_ view: SKView) {
        super.didMoveToView(view)
        
        interactionSystem.addGestureRecognizer(toView: view)
        
        #if os(macOS)
        viewSizeManager.view = view
        #endif
    }
    
    override func willMoveFromView(_ view: SKView) {
        super.willMoveFromView(view)
        
        interactionSystem.removeGestureRecognizer(fromView: view)
       
        #if os(macOS)
        viewSizeManager.view = nil
        #endif
    }
    
    override func didChangeSize(_ oldSize: Size) {
        super.didChangeSize(oldSize)
    }
    
    override func levelFileName(_ levelName: String) -> String {
        return  levelName + "-Map"
    }
    
    func makeFirework() {
        makeFirework(at: Vector(0.3, 0.4), after: 0, with: #colorLiteral(red: 0.2202886641, green: 0.7022308707, blue: 0.9593387842, alpha: 1))
        makeFirework(at: Vector(0.5, 0.6), after: 0.8, with: #colorLiteral(red: 0.4028071761, green: 0.7315050364, blue: 0.2071235478, alpha: 1), size: 300)
        makeFirework(at: Vector(0.7, 0.5), after: 0.4, with: #colorLiteral(red: 0.9101451635, green: 0.2575159371, blue: 0.1483209133, alpha: 1))
        
        makeFirework(at: Vector(0.75, 0.75), after: 0.2, with: #colorLiteral(red: 0.2202886641, green: 0.7022308707, blue: 0.9593387842, alpha: 1))
        makeFirework(at: Vector(0.25, 0.75), after: 0.6, with: #colorLiteral(red: 0.9101451635, green: 0.2575159371, blue: 0.1483209133, alpha: 1))
    }
    
    func makeFirework(at relativePosition: Vector, after timeout: TimeInterval, with color: SKColor, size: Scalar = 400) {
        timerSystem.schedule(timer: .timeout(timeout), on: self) { [unowned self] in
            let firework = Firework<TowerDefenceGame>(repeating: true, repeatDelay: 1)
            firework.relative.position = relativePosition
            firework.relative.scale = RelativeScale.toViewSizeMinWithNormalSize(of: size)
            firework.setMainColor(color)
            self.addEntityWithGame(firework)
        }
    }
}
