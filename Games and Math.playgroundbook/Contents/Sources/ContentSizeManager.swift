//
//  ContentSizeManager.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 01.08.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol GameWithContentSizeManager: Game {
    var contentSizeManager: ContentSizeManager { get }
}

struct ContentSizeState: State {
    let automatic: Bool
    let size: Size
}

func ==(lhs: ContentSizeState, rhs: ContentSizeState) -> Bool {
    return lhs.size == rhs.size
}

final class ContentSizeManager: EntityWithLayoutableComponents, LayoutableComponent, StateMachine {
    
    var layoutableComponents: [LayoutableComponent] = []
    
    var currentState = ContentSizeState(automatic: true, size: Size(100, 100))
    let didChangeState = WeakEvent<StateChangeEvent<ContentSizeState>>()
    
    init() {
        self.initComponents()
    }
    
    func initComponents() {
        addLayoutableComponent(self)
    }
    
    func layout(_ viewSize: Size) {
        if currentState.automatic {
            updateToStateIfNeeded(ContentSizeState(automatic: true, size: viewSize))
        }
    }
    
    func setContentSize(to size: Size) {
        updateToStateIfNeeded(ContentSizeState(automatic: false, size: size))
    }
}
