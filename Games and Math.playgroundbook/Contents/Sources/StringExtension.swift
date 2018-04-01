//
//  StringExtension.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 30.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

extension String {
    func trim() -> String {
        return self.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )
    }
}
