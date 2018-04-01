//
//  CGRect+extensions.swift
//  EntityComponentSystem
//
//  Created by David Nadoba on 23.03.18.
//  Copyright © 2018 David Nadoba. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGRect {
    var mid: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    mutating func inset(by inset: EdgeInsets) {
        origin.x -= inset.left
        origin.y -= inset.bottom
        size.width += inset.left
        size.width += inset.right
        size.height += inset.top
        size.height += inset.bottom
    }
    func inseted(by inset: EdgeInsets) -> CGRect {
        var rect = self
        rect.inset(by: inset)
        return rect
    }
}
