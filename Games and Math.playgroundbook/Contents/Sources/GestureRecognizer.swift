//
//  GestureRecognizer.swift
//  EntityComponentSystem
//
//  Created by David Nadoba on 23.03.18.
//  Copyright © 2018 David Nadoba. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit
typealias GestureRecognizer = UIGestureRecognizer
#endif

#if os(macOS)
import AppKit
typealias GestureRecognizer = NSGestureRecognizer
#endif
