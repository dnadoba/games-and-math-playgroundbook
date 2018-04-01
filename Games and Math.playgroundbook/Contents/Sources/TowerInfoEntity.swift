//
//  TowerInfoEntity.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 17.08.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

final class TowerInfoEntity<GameType: GameWithNodeSystem>: BasicEntityWithGame<GameType> {
    
    override func initComponents() {
        super.initComponents()
        
        rootNode.removeFromScene()
        rootNode.zIndexOffset = 10000
        
        addChildNodes()
        styleBackground()
        styleName()
        stylePrice()
        layoutNodes()
    }
    
    fileprivate let padding = Vector(5, 5)
    
    fileprivate let rect = Rectangle(center: Vector(), size: Size(300, 200))
    
    fileprivate lazy var background: SKShapeNode = SKShapeNode(rect: CGRect(self.rect), cornerRadius: 5)
    
    fileprivate let name = SKLabelNode()
    fileprivate let price = SKLabelNode()
    
    
    func show(tower info: TowerInfo) {
        name.text = info.name
        price.text = "\(info.price)💰"
        
        rootNode.removeFromScene()
        rootNode.addToScene()
    }
    
    func hide() {
        rootNode.removeFromScene()
    }
    
    fileprivate func addChildNodes() {
        addChild(background)
        addChild(name)
        addChild(price)
    }
    
    fileprivate func styleBackground() {
        background.fillColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.7961526113)
        background.strokeColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        background.lineWidth = 2
    }
    
    fileprivate func styleName() {
        name.fontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    fileprivate func stylePrice() {
        price.fontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    fileprivate func layoutNodes() {
        name.position.y = CGFloat(rect.topY - padding.y)
        name.verticalAlignmentMode = .top
        name.fontSize = 40
        
        
        price.verticalAlignmentMode = .center
        price.fontSize = 40
    }
}
