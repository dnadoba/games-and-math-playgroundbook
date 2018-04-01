//
//  GameScene.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 29.01.16.
//  Copyright (c) 2016 David Nadoba. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol GameSceneDelegate: class {
    func didMoveToView(_ view: SKView)
    func willMoveFromView(_ view: SKView)
    func didChangeSize(_ oldSize: Size)
    
}

protocol GameFocusDelegate: class {
    #if os(tvOS)
    func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool?
    var preferredFocusEnvironments: [UIFocusEnvironment] { get }
    #endif
}

protocol GameWithGameScene: Game {
    var scene: GameScene { get }
}

class GameScene: SKScene {
    
    weak var gameDelegate: GameSceneDelegate?
    
    weak var focusDelegate: GameFocusDelegate?
    
    override init() {
        super.init()
        initGameScene()
    }
    override init(size: CGSize) {
        super.init(size: size)
        initGameScene()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initGameScene()
    }
    
    fileprivate func initGameScene() {
        scaleMode = .resizeFill
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        gameDelegate?.didMoveToView(view)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        gameDelegate?.didChangeSize(Size(oldSize))
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        gameDelegate?.willMoveFromView(view)
    }
    
    #if os(tvOS)
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        focusDelegate?.didUpdateFocus(in: context, with: coordinator)
    }
    
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        return focusDelegate?.shouldUpdateFocus(in: context) ?? super.shouldUpdateFocus(in: context)
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return focusDelegate?.preferredFocusEnvironments ?? []
    }
    #endif

}
