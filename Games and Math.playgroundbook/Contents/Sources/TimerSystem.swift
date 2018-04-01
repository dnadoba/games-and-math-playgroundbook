//
//  TimerSystem.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 24.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol GameWithTimerSystem: GameWithUpdatableSystem {
    var timerSystem: TimerSystem { get }
}

enum TimerType {
    case timeout(TimeInterval)
    case interval(TimeInterval)
}

struct TimerModel {
    let type: TimerType
    var callback: TimerCallback
}

protocol EntityWithTimers: Entity {
    var timers: [TimerModel] { get set }
}

extension EntityWithGame where GameType: GameWithTimerSystem, Self: EntityWithTimers {
    func schedule(timer type: TimerType, callback: @escaping TimerCallback) {
        if let game = self.game {
            game.timerSystem.schedule(timer: type, on: self, callback: callback)
        } else {
            timers.append(
                TimerModel(type: type, callback: callback)
            )
        }
    }
}

typealias TimerCallback = () -> ()

private struct TimerInfo {
    var timeoutTime: Scalar
    var type: TimerType
    weak var observer: AnyObject?
    var callback: TimerCallback
    
    init(type: TimerType, on observer: AnyObject, callback: @escaping TimerCallback, currentTime: TimeInterval) {
        self.observer = observer
        self.callback = callback
        self.type = type
        switch type {
        case .timeout(let timeout):
            self.timeoutTime = timeout + currentTime
        case .interval(let timeout):
            self.timeoutTime = timeout + currentTime
        }
    }
    
    func followingTimer() -> TimerInfo? {
        switch type {
        case .timeout(_):
            return nil
        case .interval(_):
            guard let observer = observer else {
                return nil
            }
            return TimerInfo(type: type, on: observer, callback: callback, currentTime: timeoutTime)
        }
    }
}

final class TimerSystem: BasicSystem, EntityWithUpdatableComponents, UpdatableComponent {
    
    var updatableComponents: [(UpdateStep, (TimeInterval) -> ())] = []
    
    fileprivate var elapsedTime = Scalar()
    fileprivate var timerInfos = [TimerInfo]()
    
    var currentTime: Scalar {
        return elapsedTime
    }
    
    override func initComponents() {
        super.initComponents()
        addUpdatableComponent(updatable)
    }
    
    override func addEntity(_ entity: Entity) {
        guard let entityWithTimers = entity as? EntityWithTimers else {
            return
        }
        entityWithTimers.timers.forEach {
            self.schedule(timer: $0.type, on: entityWithTimers, callback: $0.callback)
        }
        entityWithTimers.timers.removeAll()
    }
    
    let updateStep = UpdateStep.executeTimer
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        elapsedTime += seconds
        
        //we need to copy the timerInfos because timers can be added during the evaluation of other timers
        let timerInfosToEvaluate = timerInfos
        //clear the array to allow new timers to be added
        timerInfos = []
        
        let remainingTimers = timerInfosToEvaluate.filter { (timerInfo) -> Bool in
            guard timerInfo.observer != nil else {
                return false
            }
            if timerInfo.timeoutTime <= elapsedTime {
                timerInfo.callback()
                //a timer of type interval has a following timer
                if let followingTimer = timerInfo.followingTimer() {
                    timerInfos.append(followingTimer)
                }
                return false
            }
            return true
        }
        //add the remaining timers to the new added timers
        timerInfos += remainingTimers
    }
    
    func schedule(timer type: TimerType, on observer: AnyObject, callback: @escaping TimerCallback) {
        let timerInfo = TimerInfo(type: type, on: observer, callback: callback, currentTime: currentTime)
        timerInfos.append(timerInfo)
    }
}
