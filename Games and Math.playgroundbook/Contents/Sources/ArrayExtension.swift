//
//  ArrayExtension.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 27.07.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    public subscript(safe index: Index) -> Element? {
        return index >= startIndex && index < endIndex
            ? self[index]
            : nil
    }
}
