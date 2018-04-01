//
//  Configuration.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 29.01.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import simd

public typealias Vector = double2
public typealias Scalar = Double

public typealias Vector2 = double2
public typealias Vector3 = double3

public typealias TimeInterval = Scalar

public typealias Radian = Scalar

#if os(macOS)
    import AppKit
    typealias UIColor = NSColor
#endif
