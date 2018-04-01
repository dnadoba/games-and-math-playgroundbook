//
//  File.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 09.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import simd
import SpriteKit

struct UniversalAnimationSequence: Equatable {
    let texture: UniversalTexture
    let origin: Vector
    let size: Size
    let direction: Vector
    let frameCount: Int
    let frameDuration: TimeInterval
    let looping: Bool
    
    var completeDuration: TimeInterval {
        return frameDuration * Scalar(frameCount)
    }
    
    static let defaultAnimationDirection = Vector(1, 0)
    
    static let defaultNextSequenceDirection = Vector(0, 1)
    
    init(withTexture: UniversalTexture, andSize: Size, frameCount: Int, frameDuration: TimeInterval, looping: Bool = true, atOrigin: Vector = Vector(0, 0), inDirection: Vector = UniversalAnimationSequence.defaultAnimationDirection) {
        self.texture = withTexture
        self.origin = atOrigin
        self.size = andSize
        self.direction = inDirection
        self.frameCount = frameCount
        self.frameDuration = frameDuration
        self.looping = looping
    }
    
    func normalizedFrame(_ frame: Int) ->Int {
        if !looping && frame >= frameCount {
            return frameCount - 1
        }
        return frame % frameCount
    }
    
    func offset(atFrame frame: Int) -> Vector {
        let frameId = normalizedFrame(frame)
        let offset = size * direction * Scalar(frameId)
        return origin + offset
    }
    
    func rect(atFrame frame: Int) -> CGRect {
        let position = offset(atFrame: frame)
        return CGRect(origin: CGPoint(position), size: CGSize(size))
    }
    
    func frame(forTime seconds: TimeInterval) -> Int {
        return Int(seconds/frameDuration)
    }
    func texture(atFrame frame: Int) -> SKTexture {
        let frameRect = rect(atFrame: frame)
        return texture.textureInRect(frameRect)
    }
    func sequence(atIndex index: Int, withFrameDuration newFrameDuration: Scalar, inDirection nextSequenceDirection: Vector = UniversalAnimationSequence.defaultNextSequenceDirection) -> UniversalAnimationSequence {
        return UniversalAnimationSequence(
            withTexture: texture,
            andSize: size,
            frameCount: frameCount,
            frameDuration: newFrameDuration,
            looping: looping,
            atOrigin: origin + size * nextSequenceDirection * Scalar(index),
            inDirection: direction
        )
    }
    
    func sequence(atIndex index: Int, withDuration completeDuration: Scalar, inDirection nextSequenceDirection: Vector = UniversalAnimationSequence.defaultNextSequenceDirection) -> UniversalAnimationSequence {
        return UniversalAnimationSequence(
            withTexture: texture,
            andSize: size,
            frameCount: frameCount,
            frameDuration: completeDuration/Scalar(frameCount),
            looping: looping,
            atOrigin: origin + size * nextSequenceDirection * Scalar(index),
            inDirection: direction
        )
    }
    
    func sequence(atIndex index: Int, inDirection nextSequenceDirection: Vector = UniversalAnimationSequence.defaultNextSequenceDirection) -> UniversalAnimationSequence {
        return sequence(atIndex: index, withFrameDuration: frameDuration, inDirection: nextSequenceDirection)
    }
    
    func nextSequence(inDirection nextSequenceDirection: Vector = UniversalAnimationSequence.defaultNextSequenceDirection) -> UniversalAnimationSequence {
        return sequence(atIndex: 1, inDirection: nextSequenceDirection)
    }
}

func ==(lhs: UniversalAnimationSequence, rhs: UniversalAnimationSequence) -> Bool {
    return lhs.texture === rhs.texture &&
            lhs.origin == rhs.origin &&
            lhs.size == rhs.size &&
            lhs.direction == rhs.direction &&
            lhs.frameCount == rhs.frameCount &&
            lhs.frameDuration == rhs.frameDuration
}

protocol EntityWithAnimator: EntityWithRootNode {
    var animator: AnimatorComponent<Self> { get }
}

final class AnimatorComponent<EntityType: EntityWithRootNode>: BasicComponent<EntityType>, UpdatableComponent {
    
    fileprivate(set) var animationSequence: UniversalAnimationSequence? {
        didSet {
            animationSequenceHasChanged = true
        }
    }
    fileprivate var animationSequenceHasChanged = false
    fileprivate var currentAnimationSequence: UniversalAnimationSequence?
    fileprivate var currentFrame: Int?
    
    let sprite = UniversalSprite()
    
    var offset: Vector {
        set {
            sprite.position = CGPoint(newValue)
        }
        get {
            return Vector(sprite.position)
        }
    }
    
    var zPosition: CGFloat {
        set {
            sprite.zPosition = newValue
        }
        get {
            return sprite.zPosition
        }
    }
    
    var playbackSpeed = Scalar(1)
    
    fileprivate var ellapsedTime: TimeInterval = 0
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        
        entity.addChild(sprite)
        entity.addUpdatableComponent(updatable)
    }
    
    let updateStep = UpdateStep.willRenderScene
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        ellapsedTime += seconds * playbackSpeed
        
        guard let animationSequence = animationSequence else {
            return
        }
        
        let frame = animationSequence.frame(forTime: ellapsedTime)
        
        //frame has changed
        if currentFrame != frame ||
            //animation sequence has changed but check if it is really a new value
            (animationSequenceHasChanged && animationSequence != currentAnimationSequence) {
            displayTexture(of: animationSequence, atFrame: frame)
        } else {
            animationSequenceHasChanged = false
        }
        
    }
    
    
    fileprivate func displayTexture(of sequence: UniversalAnimationSequence, atFrame frame: Int) {
        currentAnimationSequence = sequence
        animationSequenceHasChanged = false
        currentFrame = frame
        //sprite.gameSize = sequence.size
        sprite.texture = sequence.texture(atFrame: frame)
    }
    
    func play(_ animationSequence: UniversalAnimationSequence, startAtFrame startFrame: Int? = nil) {
        
        self.animationSequence = animationSequence
        
        if let frame = startFrame {
            ellapsedTime = animationSequence.frameDuration * Scalar(frame)
        }
    }
}
