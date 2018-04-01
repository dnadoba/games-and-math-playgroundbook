//
//  ViewSizeManager.swift
//  EntityComponentSystem
//
//  Created by David Nadoba on 21.03.18.
//  Copyright © 2018 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

class ViewSizeManager<GameType: GameWithContentSizeManager & GameWithContentInsetManager>: EntityWithGame {
    weak var game: GameType?
    
    
    private let contentSizeConstraint = ContentSizeConstraintComponent()
    
    var view: SKView? {
        get { return contentSizeConstraint.view }
        set { contentSizeConstraint.view = newValue }
    }
    
    private var currentRealContentSize: Size? {
        guard let game = game else { return nil }
        let contentSize = game.contentSizeManager.currentState.size
        let inset = game.contentInsetManager.bestContentInsetForCurrentDisplay() ?? EdgeInsets()
        return contentSize + Size(
            Scalar(inset.left + inset.right),
            Scalar(inset.top + inset.bottom)
        )
    }
    private var previousRealContentSize: Size?
    
    init() {
        initComponents()
    }
    
    func initComponents() {
        
    }
    
    func added(to game: GameType) {
        game.contentSizeManager.didChangeState.on(self) { [unowned self] (_) in
            self.updateContentSize()
        }
        game.contentInsetManager.didChangeState.on(self) { [unowned self] (_) in
            self.updateContentSize()
        }
        self.updateContentSize()
    }
    
    func removed(from game: GameType) {
        game.contentSizeManager.didChangeState.off(self)
        game.contentInsetManager.didChangeState.off(self)
    }
    private func updateContentSize() {
        if currentRealContentSize != previousRealContentSize {
            guard let contentSize = currentRealContentSize else { return }
            previousRealContentSize = contentSize
            contentSizeConstraint.contentSize = contentSize
        }
    }
}
