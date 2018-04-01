//
//  Component.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 29.01.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol Component {}

protocol ClassComponent: class, Component {}

protocol ComponentWithEntity: ClassComponent {
    associatedtype EntityType: Entity
    
    var unmanagedEntity: Unmanaged<EntityType>! { get set }
    
    func initComponent(withEntity entity: EntityType)
}

extension ComponentWithEntity {
    var entity: EntityType {
        get {
            return unmanagedEntity.takeUnretainedValue()
        }
        set {
            unmanagedEntity = Unmanaged.passUnretained(newValue)
        }
    }
}

extension ComponentWithEntity where EntityType: EntityWithGame {
    var game: EntityType.GameType? {
        return entity.game
    }
}

/*
extension Entity {
    func add<ComponentType: ComponentWithEntity>(component: ComponentType) where ComponentType.EntityType == Self {
        component.entity = self
        component.initComponent(withEntity: self)
    }
}
*/
