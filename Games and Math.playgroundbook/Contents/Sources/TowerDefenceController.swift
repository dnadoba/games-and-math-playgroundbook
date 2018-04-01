//
//  GameViewController.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 29.01.16.
//  Copyright (c) 2016 David Nadoba. All rights reserved.
//

import UIKit
import SpriteKit

class TowerDefenceController: BasicGameController, TowerDefenceGameDelegate {
    
    lazy var towerDefenceGame: TowerDefenceGame = TowerDefenceGame()
    
    @IBOutlet weak var startNextWaveButton: UIButton!
    @IBOutlet weak var lifePointsLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        towerDefenceGame.delegate = self
        initEventListener(on: towerDefenceGame)
        
        let levelName = "Level2"
        guard towerDefenceGame.loadLevel(levelName) else {
            fatalError("loading \(levelName) has failed")
        }
        
        self.game = towerDefenceGame
        
        let skView = self.view as! GameView
        skView.presentScene(towerDefenceGame.nodeSystem.scene)
        

        skView.showsFPS = false
        skView.showsNodeCount = false
            
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        
        skView.ignoresSiblingOrder = true
        
        updateCompleteUI()
    }
    @IBAction func toggleTowerInfoEnabledFlag(_ sender: UISwitch) {
        towerDefenceGame.shoudlShowTowerInfo(show: sender.isOn)
    }
    
    @IBAction func gameplaySpeedChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            towerDefenceGame.speed = 1
        case 1:
            towerDefenceGame.speed = 2
        case 2:
            towerDefenceGame.speed = 3
        default: break
        }
    }
    @IBAction func startNextWave() {
        towerDefenceGame.spawnSystem.startNextWave()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    fileprivate func updateCompleteUI() {
        updateStartNextWaveButton()
        updateLifePoints()
        updateMoney()
    }
    
    fileprivate func updateLifePoints() {
        lifePointsLabel.text = "\(towerDefenceGame.lifeManager.currentState.lifePoints)"
    }
    
    fileprivate func updateMoney() {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.maximumFractionDigits = 0
        formatter.currencySymbol = ""
        formatter.locale = Locale.autoupdatingCurrent
        
        moneyLabel.text = formatter.string(from: NSNumber(value: towerDefenceGame.moneyManager.currentState.money))
    }
    fileprivate func updateStartNextWaveButton() {
        let spawnState = towerDefenceGame.spawnSystem.currentState
        startNextWaveButton.isEnabled = spawnState.canStartNextWave
    }
    
    fileprivate func initEventListener(on game: TowerDefenceGame) {
        game.spawnSystem.didChangeState.on(self) { [unowned self] _ in
            self.updateStartNextWaveButton()
        }
        game.lifeManager.didChangeState.on(self) { [unowned self] _ in
            self.updateLifePoints()
        }
        game.moneyManager.didChangeState.on(self) { [unowned self] _ in
            self.updateMoney()
        }
    }
}
