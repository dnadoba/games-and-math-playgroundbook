//
//  Weak.swift
//  tower-defence
//
//  Created by David Jonas Nadoba on 07.01.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

struct Weak<T: AnyObject> {
    weak var value: T?
    init(_ value: T) {
        self.value = value
    }
    var hasReference: Bool {
        return self.value != nil
    }
}
