//
//  BasicComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 25.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

class BasicComponent<EntityType: Entity>: ComponentWithEntity {
    var unmanagedEntity: Unmanaged<EntityType>!
    
    func initComponent(withEntity entity: EntityType) {
        self.entity = entity
    }
}

class BasicComponentWithGame<GameType, EntityType: EntityWithGame>: BasicComponent<EntityType> where EntityType.GameType == GameType {
    
}
