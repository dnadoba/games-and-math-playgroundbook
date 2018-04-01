//
//  _PlaygroundValidation.swift
//  PlaygroundHelperProject
//
//  Created by David Nadoba on 01.04.18.
//  Copyright © 2018 David Nadoba. All rights reserved.
//

import Foundation
import PlaygroundSupport
public func validatePlayground(_ solution: String? = nil) {
    let hints = PlaygroundViewController.shared.getImplementationHints()
    guard hints.isEmpty else {
        PlaygroundPage.current.assessmentStatus = .fail(hints: hints, solution: solution)
        return
    }
    PlaygroundPage.current.assessmentStatus = .pass(message: nil)
}
