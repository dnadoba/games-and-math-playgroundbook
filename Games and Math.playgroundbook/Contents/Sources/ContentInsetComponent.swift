//
//  ContentInsetComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 15.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

final class ContentInsetComponent<GameType: GameWithContentInsetManager, EntityType: EntityWithGame & EntityWithLayoutableComponents>: BasicComponentWithGame<GameType, EntityType>, LayoutableComponent where EntityType.GameType == GameType {
    
    var didChangeContentInset = WeakEvent<EdgeInsets>()
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        
        entity.addLayoutableComponent(self)
    }
    
    fileprivate var lastInset: EdgeInsets?
    
    func layout(_ viewSize: Size) {
        let inset = game?.contentInsetManager.bestContentInset(forAspectRatio: viewSize.aspectRatio) ?? EdgeInsets()
        if lastInset != inset {
            lastInset = inset
            didChangeContentInset.emit(inset)
        }
    }
}
