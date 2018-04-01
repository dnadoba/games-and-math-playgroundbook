//
//  InteractionSystem.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 13.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif


protocol Interactable: class {
    var isInteractable: Bool { get }
    var position: PositionComponent { get }
    var shape: ShapeComponent { get }
    #if os(tvOS)
    var focusItem: UIFocusItem { get }
    #endif
    
    //MARK: Events
    var tap: WeakEvent<TapEvent> { get }
    #if os(tvOS)
    var focusUpdate: WeakEvent<FocusUpdateEvent> { get }
    #endif
}
extension Interactable {
    func intersect(with point: Vector) -> Bool {
        switch shape{
        case .circle(let radius):
            let distance = point.distanceTo(position)
            return distance < radius
        case .rectangle(let size):
            let rect = Rectangle(center: position, size: size)
            return rect.intersect(with: point)
        }
    }
}

protocol InteractableEntity: Entity {
    var interactable: Interactable { get }
}


protocol GameWithInteractionSystem: GameWithNodeSystem {
    var interactionSystem: InteractionSystem<Self> { get }
}

protocol FocusInterceptorDelegate: class {
    #if os(tvOS)
    func can(focus interactable: Interactable) -> Bool?
    #endif
}

final class InteractionSystem<GameType: GameWithNodeSystem & GameWithUpdatableSystem>: BasicSystemWithGame<GameType>, GameFocusDelegate {
    
    // MARK: Events
    let tap = WeakEvent<TapEvent>()
    let tapFallThrough = WeakEvent<TapEvent>()
    
    weak var focusInterceptorDelegate: FocusInterceptorDelegate?
    
    fileprivate var view: View?
    
    #if os(tvOS)
    private var focusedInteractable: Interactable?
    #endif
    
    fileprivate var interactables: [Interactable] = []
    #if os(iOS) || os(tvOS)
    fileprivate lazy var tapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(InteractionSystem.handleTap(_:)))
        #if os(tvOS)
            gestureRecognizer.allowedPressTypes = [NSNumber(value: UIPressType.select.rawValue)]
        #endif
        return gestureRecognizer
        }()
    #endif
    #if os(macOS)
    fileprivate lazy var tapGestureRecognizer: NSClickGestureRecognizer = { [unowned self] in
        let gestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(InteractionSystem.handleClick(_:)))
        
        return gestureRecognizer
        }()
    #endif
    //private lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = { [unowned self] in
    //    return UILongPressGestureRecognizer(target: self, action: #selector(InputSystem.handleLongPress(_:)))
    //}()
    fileprivate var allGestureRecognizer: [GestureRecognizer] {
        return [
            tapGestureRecognizer,
            //longPressGestureRecognizer,
        ]
    }
    
    override func addEntity(_ entity: Entity) {
        guard let entity = entity as? InteractableEntity else {
            return
        }
        interactables.append(entity.interactable)
    }
    
    override func removeEntity(_ entity: Entity) {
        guard let entity = entity as? InteractableEntity else {
            return
        }
        if let index = interactables.index(where: { $0 === entity.interactable }) {
            interactables.remove(at: index)
        }
    }
    
    func interactable(atPoint point: Vector) -> [Interactable] {
        return interactables.filter {
            return $0.isInteractable && $0.intersect(with: point)
        }
    }
    
    func addGestureRecognizer(toView view: View) {
        self.view = view
        allGestureRecognizer.forEach(view.addGestureRecognizer)
    }
    func removeGestureRecognizer(fromView view: View) {
        allGestureRecognizer.forEach(view.removeGestureRecognizer)
        self.view = nil
    }
    
    private func locationInGame(_ sender: GestureRecognizer) -> Vector? {
        let point = sender.location(in: view)
        return game?.nodeSystem.convertPoint(Vector(point))
    }
    
    private func handleInteraction(_ sender: GestureRecognizer) {
        if sender.state == .ended {
            guard let pointInGame = locationInGame(sender) else {
                return
            }
            let interactablesAtPoint = interactable(atPoint: pointInGame)
            
            if interactablesAtPoint.isEmpty {
                handleTapFallThrough(at: pointInGame)
            } else {
                for interactable in interactablesAtPoint {
                    let event = TapEvent(at: pointInGame, on: interactable)
                    interactable.tap.emit(event)
                    tap.emit(event)
                }
            }
        }
    }
    fileprivate func handleTapFallThrough(at point: Vector) {
        let event = TapEvent(at: point, on: nil)
        tap.emit(event)
        tapFallThrough.emit(event)
    }
    #if os(iOS)
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        handleInteraction(sender)
    }
    
    #endif
    
    #if os(tvOS)
    var preferredFocusEnvironments: [UIFocusEnvironment] {
        return interactables.map { $0.focusItem }.reversed()
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if let focusedInteractable = focusedInteractable,
                focusedInteractable.isInteractable {
                
                let position = focusedInteractable.position
                let event = TapEvent(at: position, on: focusedInteractable)
                focusedInteractable.tap.emit(event)
                tap.emit(event)
            }
        }
    }
    func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let node = context.nextFocusedItem as? InteractableNode,
            let interactable = node.interactable {
            focusedInteractable = interactable
        } else {
            focusedInteractable = nil
        }
    }
    func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool? {
        guard let node = context.nextFocusedItem as? InteractableNode,
            let interactable = node.interactable else {
            return nil
        }
        
        return can(focus: interactable)
    }
    
    func can(focus interactable: Interactable) -> Bool? {
        return focusInterceptorDelegate?.can(focus: interactable)
    }
    
    func setNeedsFocusUpdate() {
        game?.scene.setNeedsFocusUpdate()
    }
    #endif
    
    #if os(macOS)
    @objc func handleClick(_ sender: NSClickGestureRecognizer) {
        handleInteraction(sender)
    }
    #endif
}
