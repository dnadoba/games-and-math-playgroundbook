//
//  UniversalEmitter.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 09.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

struct EmitterProperties {
    let particleBirthRate: CGFloat
    let numParticlesToEmit: Int
    let particleRenderOrder: SKParticleRenderOrder
    let particleLifetime: CGFloat
    let particleLifetimeRange: CGFloat
    
    let particlePosition: CGPoint
    let particlePositionRange: CGVector
    let particleZPosition: CGFloat
    let particleSpeed: CGFloat
    
    let emissionAngle: CGFloat
    let emissionAngleRange: CGFloat
    
    let xAcceleration: CGFloat
    let yAcceleration: CGFloat
    
    let particleRotation: CGFloat
    let particleRotationRange: CGFloat
    let particleRotationSpeed: CGFloat
    
    let particleScaleSequence: SKKeyframeSequence?
    let particleScale: CGFloat
    let particleScaleRange: CGFloat
    let particleScaleSpeed: CGFloat
    
    //texture, color and blend mode is missing
    let particleAlphaSequence: SKKeyframeSequence?
    let particleAlpha: CGFloat
    let particleAlphaRange: CGFloat
    let particleAlphaSpeed: CGFloat
    
    init(fromEmitter emitter: SKEmitterNode) {
        particleBirthRate = emitter.particleBirthRate
        numParticlesToEmit = emitter.numParticlesToEmit
        particleRenderOrder = emitter.particleRenderOrder
        particleLifetime = emitter.particleLifetime
        particleLifetimeRange = emitter.particleLifetimeRange
            
        particlePosition = emitter.particlePosition
        particlePositionRange = emitter.particlePositionRange
        particleZPosition = emitter.particleZPosition
        particleSpeed = emitter.particleSpeed
        
        emissionAngle = emitter.emissionAngle
        emissionAngleRange = emitter.emissionAngleRange
        
        xAcceleration = emitter.xAcceleration
        yAcceleration = emitter.yAcceleration
        
        particleRotation = emitter.particleRotation
        particleRotationRange = emitter.particleRotationRange
        particleRotationSpeed = emitter.particleRotationSpeed
            
        particleScaleSequence = emitter.particleScaleSequence
        particleScale = emitter.particleScale
        particleScaleRange = emitter.particleScaleRange
        particleScaleSpeed = emitter.particleScaleSpeed
        
        particleAlphaSequence = emitter.particleAlphaSequence
        particleAlpha = emitter.particleAlpha
        particleAlphaRange = emitter.particleAlphaRange
        particleAlphaSpeed = emitter.particleAlphaSpeed
    }
}

final class UniversalEmitter: SKEmitterNode {
    
    var inital: EmitterProperties!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        inital = EmitterProperties(fromEmitter: self)
    }
    
    
    static func fromFileNamed(_ fileNamed: String) -> UniversalEmitter?{
        guard let path = Bundle.main.path(forResource: fileNamed, ofType: "sks"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path))else {
            return nil
        }
        
        let archiver = NSKeyedUnarchiver(forReadingWith: data)
        archiver.setClass(self, forClassName: "SKEmitterNode")
        
        return archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? UniversalEmitter
    }
}
