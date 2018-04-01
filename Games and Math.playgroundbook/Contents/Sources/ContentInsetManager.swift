//
//  ContentInsetManager.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 01.08.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

typealias AspectRatio = Scalar

protocol GameWithContentInsetManager: Game {
    var contentInsetManager: ContentInsetManager { get }
}

struct ContentInsetInfo: Equatable {
    let aspect: Scalar
    let inset: EdgeInsets
}
#if swift(>=4.1)
#else
    extension ContentInsetInfo {
        static func ==(lhs: ContentInsetInfo, rhs: ContentInsetInfo) -> Bool {
            return lhs.aspect == rhs.aspect && lhs.inset == rhs.inset
        }
    }
#endif


struct ContentInsetState: Equatable, State {
    var insets: [ContentInsetInfo]
    
    func addContentInsets(_ insets: [ContentInsetInfo]) -> ContentInsetState {
        var newState = self
        newState.insets += insets
        return newState
    }
}
#if swift(>=4.1)
#else
    extension ContentInsetState {
        static func ==(lhs: ContentInsetState, rhs: ContentInsetState) -> Bool {
            return lhs.insets == rhs.insets
        }
    }
#endif

final class ContentInsetManager: StateMachine {
    
    var currentState = ContentInsetState(insets: [])
    let didChangeState = WeakEvent<StateChangeEvent<ContentInsetState>>()
    
    func addContentInset(_ insets: [ContentInsetInfo]) {
        updateToStateIfNeeded(currentState.addContentInsets(insets))
    }
    
    func bestContentInset(forAspectRatio aspectRatio: AspectRatio) -> EdgeInsets? {
        let orderedContentInsets = currentState.insets.map { (content) in
            return (
                distance: abs(aspectRatio - content.aspect),
                inset: content.inset
            )
            }.sorted { (lhs, rhs) in lhs.distance < rhs.distance }
        return orderedContentInsets.first?.inset
    }
    
    func bestContentInsetForCurrentDisplay() -> EdgeInsets? {
        return bestContentInset(forAspectRatio: 16/9)
    }
}
