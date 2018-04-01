//
//  Camera.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 10.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

import SpriteKit

protocol EntityWithSKCameraNode {
    var cameraNode: SKCameraNode { get }
}

final class Camera<GameType: GameWithNodeSystem & GameWithContentSizeManager & GameWithContentInsetManager>: BasicEntityWithGame<GameType>, EntityWithSKCameraNode, EntityWithLayoutableComponents {
    
    var layoutableComponents: [LayoutableComponent] = []
    
    let cameraNode = SKCameraNode()
    #if os(iOS) || os(tvOS)
    let scrollView = CameraScrollViewComponent<Camera<GameType>>()
    #endif
    #if os(macOS)
    var contentSize: Size? {
        return game?.contentSizeManager.currentState.size
    }
    let focusComponent = CameraFocusComponent<GameType, Camera>()
    #endif
    let contentInset = ContentInsetComponent<GameType, Camera<GameType>>()
    
    override func initComponents() {
        super.initComponents()
        #if os(iOS) || os(tvOS)
        scrollView.initComponent(withEntity: self)
        #endif
        #if os(macOS)
        focusComponent.initComponent(withEntity: self)
        #endif
        contentInset.initComponent(withEntity: self)
        addChild(cameraNode)
        
        contentInset.didChangeContentInset.on(self) { [unowned self] (contentInset) in
            #if os(iOS) || os(tvOS)
            self.scrollView.contentInset = contentInset
            self.scrollView.zoomOut()
            #endif
            #if os(macOS)
            self.updateFocusIfNeeded()
            #endif
        }
    }
    
    override func added(to game: GameType) {
        super.added(to: game)
        
        game.contentSizeManager.didChangeState.on(self) { [unowned self] (stateChange) in
            let contentSize = stateChange.currentState.size
            
            #if os(iOS) || os(tvOS)
            self.scrollView.contentSize = contentSize
            #endif
            #if os(macOS)
            self.updateFocusIfNeeded()
            #endif
        }
    }
    
    #if os(macOS)
    private func updateFocusIfNeeded() {
        
        guard let contentSize = contentSize else { return }
        let edgeInset = game?.contentInsetManager.bestContentInsetForCurrentDisplay() ?? EdgeInsets()
        
        var rect = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
        rect.inset(by: edgeInset)
        
        focusComponent.focus(rect: rect)
    }
    #endif
    
    override func removed(from game: GameType) {
        super.removed(from: game)
        game.contentSizeManager.didChangeState.off(self)
    }
}
