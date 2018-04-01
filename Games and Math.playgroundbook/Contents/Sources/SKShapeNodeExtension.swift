//
//  SKShapeNodeExtension.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 09.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

extension SKShapeNode {
    convenience init(path: [Vector]) {
        guard path.count >= 2 else {
            self.init()
            return
        }
        let cgPath = CGMutablePath()
        let firstPoint = path.first!
        cgPath.moveToPoint(firstPoint)
        path[1..<path.count].forEach(cgPath.addLineToPoint)
        self.init(path: cgPath)
    }
    convenience init(rectOfSize size: Size) {
        self.init(rectOf: CGSize(size))
    }
    convenience init(rectOfSize size: Size, cornerRadius: Scalar) {
        self.init(rectOf: CGSize(size), cornerRadius: CGFloat(cornerRadius))
    }
}
