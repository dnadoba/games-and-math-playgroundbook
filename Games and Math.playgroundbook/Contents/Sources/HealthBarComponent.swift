//
//  HealthBarComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 09.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

struct HealthBarStyle: Equatable {
    let backgroundFillColor: UIColor
    let backgroundStrokeColor: UIColor
    
    let hitPointsBarFillColor: UIColor
    let hitPointsBarStrokeColor: UIColor
    init(backgroundFillColor: UIColor, withStrokeColor backgroundStrokeColor: UIColor, andHitPointsBarFillColor hitPointsBarFillColor: UIColor, withStrokeColor hitPointsBarStrokeColor: UIColor) {
        self.backgroundFillColor = backgroundFillColor
        self.backgroundStrokeColor = backgroundStrokeColor
        self.hitPointsBarFillColor = hitPointsBarFillColor
        self.hitPointsBarStrokeColor = hitPointsBarStrokeColor
    }
    static var normal = HealthBarStyle(backgroundFillColor: .black, withStrokeColor: .clear, andHitPointsBarFillColor: .green, withStrokeColor: .clear)
    static var warning = HealthBarStyle(backgroundFillColor: .black, withStrokeColor: .clear, andHitPointsBarFillColor: .orange, withStrokeColor: .clear)
    static var critical = HealthBarStyle(backgroundFillColor: .black, withStrokeColor: .clear, andHitPointsBarFillColor: .red, withStrokeColor: .clear)
}

func ==(lhs: HealthBarStyle, rhs:HealthBarStyle) -> Bool {
    return lhs.backgroundFillColor == rhs.backgroundFillColor &&
        lhs.backgroundStrokeColor == rhs.backgroundStrokeColor &&
        lhs.hitPointsBarFillColor == rhs.hitPointsBarFillColor &&
        lhs.hitPointsBarStrokeColor == rhs.hitPointsBarStrokeColor
}

final class HealthBarComponent<EntityType: EntityWithRootNode & EntityWithUpdatableComponents & EntityWithHealthAttribute>: BasicComponent<EntityType>, UpdatableComponent {
    
    var offset = Vector() { didSet { updateShapes() } }
    
    var size = Size(28, 9) { didSet { updateShapes() } }
    
    var stylesForHealthState: [(percentage: Scalar, style: HealthBarStyle)] = [
        (1, HealthBarStyle.normal),
        (0.75, HealthBarStyle.warning),
        (0.3, HealthBarStyle.critical),
        ] { didSet { updateShapes() } }
    
    fileprivate(set) var currentStyle: HealthBarStyle = HealthBarStyle.normal {
        didSet {
            //check if the value has changed
            if oldValue != currentStyle {
                updateBackgroundShape()
                updateHitPointsBarStyle()
            }
        }
    }
    
    fileprivate func styleForHealth(inPercantage healthInPercentage: Scalar) -> HealthBarStyle {
        var bestStyle = stylesForHealthState.first?.style ?? HealthBarStyle.normal
        
        for styleForHealthState in stylesForHealthState.sorted(by: { $0.percentage > $1.percentage }) {
            if styleForHealthState.percentage >= healthInPercentage {
                bestStyle = styleForHealthState.style
            }
        }
        return bestStyle
    }
    
    fileprivate var backgroundSize: Size { return size }
    
    fileprivate var hitPointsBarInset = Vector(2, 2) { didSet { updateShapes() } }
    
    fileprivate var maxWidthOfHitPointsBar: Scalar {
        return size.width - hitPointsBarInset.x * 2
    }
    fileprivate var widthOfHitPointsBar: Scalar {
        return maxWidthOfHitPointsBar * entity.health.inPercentage
    }
    
    fileprivate var hitPointsBarSize: Size {
        return Size(maxWidthOfHitPointsBar, size.height - hitPointsBarInset.y * 2)
    }
    
    fileprivate var isVisible: Bool {
        return entity.health.isAlive && entity.health.inPercentage < 1
    }
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        
        entity.addUpdatableComponent(updatable)
    }
    
    fileprivate var lastBackgroundSize = Size()
    
    fileprivate func updateShapes() {
        updateBackgroundShape()
        updateHitPointsBarShape()
    }
    
    fileprivate var backgroundShape: SKShapeNode?
    fileprivate func updateBackgroundShape() {
        backgroundShape?.removeFromParent()
        
        let newBackgroundShape = SKShapeNode(rectOfSize: backgroundSize)
        newBackgroundShape.isHidden = !isVisible
        newBackgroundShape.zPosition = 500
        newBackgroundShape.position = CGPoint(offset)
        newBackgroundShape.fillColor = currentStyle.backgroundFillColor
        newBackgroundShape.strokeColor = currentStyle.backgroundStrokeColor
        
        entity.addChild(newBackgroundShape)
        backgroundShape = newBackgroundShape
    }
    
    fileprivate var hitPointsShape: SKShapeNode?
    fileprivate func updateHitPointsBarShape() {
        hitPointsShape?.removeFromParent()
        
        let newHitPointsShape = SKShapeNode(rectOfSize: hitPointsBarSize)
        newHitPointsShape.isHidden = !isVisible
        newHitPointsShape.zPosition = 1000
        newHitPointsShape.position = CGPoint(offset)

        
        
        
        entity.addChild(newHitPointsShape)
        hitPointsShape = newHitPointsShape
        
        updateHitPointsBarStyle()
        updateHitPointsBarScaleAndPosition()
    }
    
    fileprivate func updateHitPointsBarStyle() {
        hitPointsShape?.fillColor = currentStyle.hitPointsBarFillColor
        hitPointsShape?.strokeColor = currentStyle.hitPointsBarStrokeColor
    }
    
    fileprivate func updateHitPointsBarScaleAndPosition() {
        hitPointsShape?.position = CGPoint(offset)
        //the rect is centered but we want the HitPointsBar aligned to the left side
        hitPointsShape?.position.x -= CGFloat((maxWidthOfHitPointsBar - widthOfHitPointsBar) / 2)
        hitPointsShape?.xScale = CGFloat(entity.health.inPercentage)
    }
    
    fileprivate func updateVisibility() -> Bool {
        let visible = isVisible
        backgroundShape?.isHidden = !visible
        hitPointsShape?.isHidden = !visible
        return visible
    }
    
    let updateStep = UpdateStep.willRenderScene
    
    fileprivate var lastHealthPercentage: Scalar?
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        guard updateVisibility() else {
            return
        }
        let currentHealthPercentage = entity.health.inPercentage
        if currentHealthPercentage != lastHealthPercentage {
            currentStyle = styleForHealth(inPercantage: currentHealthPercentage)
            updateHitPointsBarScaleAndPosition()
            lastHealthPercentage = currentHealthPercentage
        }
        
    }

}
