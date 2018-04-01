//
//  EdgeInsets.swift
//  EntityComponentSystem
//
//  Created by David Nadoba on 21.03.18.
//  Copyright © 2018 David Nadoba. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS)
import UIKit

typealias EdgeInsets = UIEdgeInsets
#else
struct EdgeInsets: Equatable {
    var top: CGFloat
    var left: CGFloat
    var bottom: CGFloat
    var right: CGFloat
    init() {
        self.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.top = top
        self.left =  left
        self.bottom = bottom
        self.right = right
    }
}
#if swift(>=4.1)
#else
    extension EdgeInsets {
        static func ==(lhs: EdgeInsets, rhs: EdgeInsets) -> Bool {
            return lhs.top == rhs.top && lhs.left == rhs.left && lhs.bottom == rhs.bottom && lhs.right == rhs.right
        }
    }
#endif
    
    
#endif
