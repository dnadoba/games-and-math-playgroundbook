//
//  ContentInsetLoader.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 15.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

final class ContentInsetLoader<GameType: GameWithContentInsetManager>: LevelLoader {
    unowned var game: GameType
    init(game: GameType) {
        self.game = game
    }
    func loadLevel(_ sceneModel: SKNode, withName: String) -> Bool{
        guard let scene = sceneModel as? SKScene else {
            return false
        }
        
        let contentSize = scene.size
        
        let contentInsetsForAspectRatio = scene.childNode(withName: "contentInset")?.children.flatMap { child -> ContentInsetInfo? in
            guard let view = child as? SKSpriteNode else {
                return nil
            }
            let rect = view.frame
            
            let inset = EdgeInsets(
                top: rect.maxY - contentSize.height,
                left: -rect.minX,
                bottom: -rect.minY,
                right: rect.maxX - contentSize.width
            )
            
            return ContentInsetInfo(
                aspect: Scalar(rect.width/rect.height),
                inset: inset.clamp(toMinInset: 0)
            )
        }
        
        if let configuration = contentInsetsForAspectRatio,
            configuration.count > 0 {
            game.contentInsetManager.addContentInset(configuration)
        } else {
            print("no content inset configuration found")
        }
        
        
        
        return true
    }
}

extension EdgeInsets {
    func clamp(toMinInset value: CGFloat) -> EdgeInsets {
        return EdgeInsets(
            top: min(value, self.top),
            left: min(value, self.left),
            bottom: min(value, self.bottom),
            right: min(value, self.right)
        )
    }
    func clamp(toMaxInset value: CGFloat) -> EdgeInsets {
        return EdgeInsets(
            top: max(value, self.top),
            left: max(value, self.left),
            bottom: max(value, self.bottom),
            right: max(value, self.right)
        )
    }
}


