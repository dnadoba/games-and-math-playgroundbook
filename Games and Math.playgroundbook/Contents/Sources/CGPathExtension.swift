//
//  CGPathExtension.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 09.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGMutablePath {
    func moveToPoint(_ point: Vector) {
        self.move(to: CGPoint(point))
    }
    func addLineToPoint(_ point: Vector) {
        self.addLine(to: CGPoint(point))
    }
}
