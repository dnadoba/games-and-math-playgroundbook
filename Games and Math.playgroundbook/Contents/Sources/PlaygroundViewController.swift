//
//  PlaygroundControllerViewController.swift
//  EntityComponentSystem
//
//  Created by David Nadoba on 01.04.18.
//  Copyright © 2018 David Nadoba. All rights reserved.
//

import UIKit
import SpriteKit
import PlaygroundSupport

public class PlaygroundViewController: BasicGameController, TowerDefenceGameDelegate, PlaygroundLiveViewSafeAreaContainer {
    static public let shared = PlaygroundViewController()
    static private func makeStartNextWaveButton() -> UIButton {
        let button = UIButton.init(type: .custom)
        button.setTitle("Start Next Wave", for: .normal)
        button.setTitleColor(UIColor.lightText, for: .disabled)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    static private func makeLifePointsLabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    static private func makeMoneyLabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static private func makeGameSpeedSegmentedControl() -> UISegmentedControl {
        let segmentedControl = UISegmentedControl.init(items: ["1x", "2x", "3x"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }

    private lazy var towerDefenceGame: TowerDefenceGame = TowerDefenceGame()
    private let startNextWaveButton: UIButton = PlaygroundViewController.makeStartNextWaveButton()
    private let lifePointsLabel: UILabel = PlaygroundViewController.makeLifePointsLabel()
    private let moneyLabel: UILabel = PlaygroundViewController.makeMoneyLabel()
    private let gameSpeedSegmentedControl = PlaygroundViewController.makeGameSpeedSegmentedControl()
    
    // playground support
    public var isTargetInRangeSquared: CustomIsTargetFunction? {
        get { return towerDefenceGame.targetableSystem.customIsTargetFunction }
        set { towerDefenceGame.targetableSystem.customIsTargetFunction = newValue }
    }
    public var isTargetInRange: CustomIsTargetFunction? {
        get { return towerDefenceGame.targetableSystem.customIsTargetFunction }
        set {
            guard let isTargetInRange = newValue else {
                towerDefenceGame.targetableSystem.customIsTargetFunction = nil
                return
            }
            let wrapperFunction = { (targetPosition: Vector, towerPosition: Vector, maxDistanceSquared: Scalar) -> Bool in
                return isTargetInRange(targetPosition, towerPosition, sqrt(maxDistanceSquared))
            }
            towerDefenceGame.targetableSystem.customIsTargetFunction = wrapperFunction
        }
    }
    
    public var automaticallyStartFirstWave = true
    public var automaticallyBuildFirstTowers = true

    private func initUI() {
        view.addSubview(startNextWaveButton)
        view.addSubview(lifePointsLabel)
        view.addSubview(moneyLabel)
        view.addSubview(gameSpeedSegmentedControl)
        
        startNextWaveButton.addTarget(self, action: #selector(self.startNextWave), for: .touchUpInside)
        gameSpeedSegmentedControl.addTarget(self, action: #selector(self.gameplaySpeedChanged(_:)), for: .valueChanged)
        
        // constains
        
        
        
        NSLayoutConstraint.activate([
            // start next wave button
            
            startNextWaveButton.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: 32),
            liveViewSafeAreaGuide.trailingAnchor.constraint(equalTo: startNextWaveButton.trailingAnchor, constant: 32),
            
            // money label
            liveViewSafeAreaGuide.bottomAnchor.constraint(equalTo: moneyLabel.bottomAnchor, constant: 32),
            moneyLabel.leadingAnchor.constraint(equalTo: liveViewSafeAreaGuide.leadingAnchor, constant: 32),
            
            // life points label
            lifePointsLabel.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: 32),
            lifePointsLabel.leadingAnchor.constraint(equalTo: liveViewSafeAreaGuide.leadingAnchor, constant: 32),
            
            // game speed segmneted control
            liveViewSafeAreaGuide.bottomAnchor.constraint(equalTo: gameSpeedSegmentedControl.bottomAnchor, constant: 32),
            liveViewSafeAreaGuide.trailingAnchor.constraint(equalTo: gameSpeedSegmentedControl.trailingAnchor, constant: 32),
            
        ])
        
//        NSLayoutConstraint.activate([
//            // start next wave button
//
//            startNextWaveButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 64),
//            view.trailingAnchor.constraint(equalTo: startNextWaveButton.trailingAnchor, constant: 32),
//
//            // money label
//            bottomLayoutGuide.topAnchor.constraint(equalTo: moneyLabel.bottomAnchor, constant: 64),
//            moneyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
//
//            // life points label
//            lifePointsLabel.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 64),
//            lifePointsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
//
//            // game speed segmneted control
//            bottomLayoutGuide.topAnchor.constraint(equalTo: gameSpeedSegmentedControl.bottomAnchor, constant: 64),
//            view.trailingAnchor.constraint(equalTo: gameSpeedSegmentedControl.trailingAnchor, constant: 32),
//
//            ])
    }
    
    public override func loadView() {
        view = GameView()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        
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
        if automaticallyStartFirstWave {
            startNextWave()
        }
        
        if automaticallyBuildFirstTowers {
            buildTowerAtNextFreePlace(type: .fireball)
            buildTowerAtNextFreePlace(type: .ice)
        }
    }
    
    public func addMoney(_ amount: Int) {
        towerDefenceGame.moneyManager.addMoney(amount)
    }
    
    public func buildTowerAtNextFreePlace(type: TowerType) {
        let buildPlaces = towerDefenceGame.getTowerBuildPlaces()
        if let towerBuildPlace = buildPlaces.first {
            towerBuildPlace.buildTower(type: type)
        }
    }
    
    @objc func gameplaySpeedChanged(_ sender: UISegmentedControl) {
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
    @objc public func startNextWave() {
        towerDefenceGame.spawnSystem.startNextWave()
    }
    
    fileprivate func updateCompleteUI() {
        updateStartNextWaveButton()
        updateLifePoints()
        updateMoney()
    }
    
    fileprivate func updateLifePoints() {
        lifePointsLabel.text = "❤️  \(towerDefenceGame.lifeManager.currentState.lifePoints)"
    }
    
    fileprivate func updateMoney() {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.maximumFractionDigits = 0
        formatter.currencySymbol = ""
        formatter.locale = Locale.autoupdatingCurrent
        
        moneyLabel.text = "💵 " + (formatter.string(from: NSNumber(value: towerDefenceGame.moneyManager.currentState.money)) ?? "")
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
    
    let positions: [(enemy: Vector, tower: Vector)] = [
        (Vector(10, 10), Vector(5, 5)),
        (Vector(10, 10), Vector(5, 0)),
        (Vector(10, 10), Vector(0, 0)),
        (Vector(10, 0), Vector(0, 0)),
        (Vector(0, 0), Vector(0, 0)),
        ]
    func doesNotTargetEnemiesInRange(implementation isTargetInRange: (_ targetPosition: Vector, _ towerPosition: Vector, _ maxDistanceSquared: Scalar) -> Bool) -> String? {
        
        for (enemyPosition, towerPosition) in positions {
            let expectedDistance = distance_squared(enemyPosition, towerPosition)
            let maxDistance = expectedDistance + 0.01
            let result = isTargetInRange(enemyPosition, towerPosition, maxDistance)
            
            if result == false {
                return "Your function does not target all enemies in range"
            }
        }
        return nil
    }
    func doesTargetEnemiesOutsideOfRange(implementation isTargetInRange: (_ targetPosition: Vector, _ towerPosition: Vector, _ maxDistanceSquared: Scalar) -> Bool) -> String? {
        
        for (enemyPosition, towerPosition) in positions {
            let expectedDistance = distance_squared(enemyPosition, towerPosition)
            let maxDistance = expectedDistance - 0.01
            let result = isTargetInRange(enemyPosition, towerPosition, maxDistance)
            
            if result == true {
                return "Your function does target enemies who are not in range"
            }
        }
        return nil
    }
    
    public func getImplementationHints() -> [String] {
        guard let isTargetInRangeSquared = towerDefenceGame.targetableSystem.customIsTargetFunction else {
            return []
        }
        return [
            doesNotTargetEnemiesInRange(implementation: isTargetInRangeSquared),
            doesTargetEnemiesOutsideOfRange(implementation: isTargetInRangeSquared),
        ].flatMap { $0 }
    }
}
