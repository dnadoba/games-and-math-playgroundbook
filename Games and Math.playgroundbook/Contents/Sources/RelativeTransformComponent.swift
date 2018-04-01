//
//  RelativeTransformComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 31.07.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import simd

typealias RelativePosition = Vector

enum RelativeScale {
    case absolute(Vector)
    case toViewSize(Vector)
    case toViewSizeMin(Scalar)
    case toViewSizeMax(Scalar)
    case toViewSizeWidth(Scalar)
    case toViewSizeHeight(Scalar)
    
    static func toViewSizeMinWithNormalSize(of value: Scalar) -> RelativeScale {
        return RelativeScale.toViewSizeMin(1/value)
    }
    
    static func toViewSizeMaxWithNormalSize(of value: Scalar) -> RelativeScale {
        return RelativeScale.toViewSizeMax(1/value)
    }
    
    func computeScale(for viewSize: Size) -> Vector {
        switch self {
        case .absolute(let scale):
            return scale
        case .toViewSize(let scale):
            return viewSize * scale
        case .toViewSizeMin(let scale):
            return Vector(viewSize.min * scale)
        case .toViewSizeMax(let scale):
            return Vector(viewSize.max * scale)
        case .toViewSizeWidth(let scale):
            return Vector(viewSize.width * scale)
        case .toViewSizeHeight(let scale):
            return Vector(viewSize.height * scale)
        }
    }
}

protocol RelativeTransformableEntity: TransformableEntity, EntityWithLayoutableComponents {
    var relative: RelativeTransformComponent<Self> { get }
}

final class RelativeTransformComponent<EntityType: TransformableEntity & EntityWithLayoutableComponents>: BasicComponent<EntityType>, LayoutableComponent {
    
    var position: RelativePosition = Vector() { didSet{ updatePosition() } }
    var scale: RelativeScale = RelativeScale.absolute(Vector(1, 1)) { didSet{ updateScale() } }
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        
        entity.addLayoutableComponent(self)
    }
    
    fileprivate var viewSize: Size?
    
    func layout(_ viewSize: Size) {
        self.viewSize = viewSize
        updatePosition()
        updateScale()
    }
    
    fileprivate func updatePosition() {
        guard let viewSize = viewSize else {
            return
        }
        entity.position = viewSize * (position - Vector(0.5, 0.5))
    }
    
    fileprivate func updateScale() {
        guard let viewSize = viewSize else {
            return
        }
        entity.scale = scale.computeScale(for: viewSize)
    }
}
