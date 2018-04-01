//
//  View.swift
//  EntityComponentSystem
//
//  Created by David Nadoba on 23.03.18.
//  Copyright © 2018 David Nadoba. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit
typealias View = UIView
#endif

#if os(macOS)
import AppKit
typealias View = NSView
#endif
