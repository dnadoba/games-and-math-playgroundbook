//
//  InteractionComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 05.07.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit
#if os(tvOS)
import UIKit
#endif

struct TapEvent {
    let position: Vector
    weak var interactable: Interactable?
    init(at position: Vector, on interactable: Interactable?) {
        self.position = position
        self.interactable = interactable
    }
}
#if os(tvOS)
struct FocusUpdateEvent {
    let isFocused: Bool
}
#endif

protocol EntityWithInteraction: EntityWithRootNode, InteractableEntity {
    associatedtype InteractableType: Interactable
    var interaction: InteractableType { get }
}

extension EntityWithInteraction {
    var interactable: Interactable {
        return interaction
    }
}

protocol NodeInteractionDelegate: class {
    #if os(tvOS)
    func canBecomeFocused() -> Bool
    func didBecomeFocused()
    func willLostFocus()
    #endif
}

final class InteractableNode: SKSpriteNode {
    weak var interactable: Interactable?
    weak var delegate: NodeInteractionDelegate? {
        didSet {
            self.isUserInteractionEnabled = delegate != nil
        }
    }
    
    #if os(tvOS)
    
    override var canBecomeFocused: Bool {
        return delegate?.canBecomeFocused() ?? false
    }
    
    private(set) var isFocused = false {
        didSet {
            //value has really changed
            guard isFocused != oldValue else {
                return
            }
            if isFocused {
                delegate?.didBecomeFocused()
                self.becomeFirstResponder()
            } else {
                delegate?.willLostFocus()
            }
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let nextFocusedItem = context.nextFocusedItem as? InteractableNode,
            nextFocusedItem == self {
            isFocused = true
        } else {
            isFocused = false
        }
    }
    
    #endif 
    
}

final class InteractionComponent<GameType: GameWithGameScene & GameWithInteractionSystem, EntityType: EntityWithGame & EntityWithRootNode & EntityWithUpdatableComponents>: BasicComponentWithGame<GameType, EntityType>, NodeInteractionDelegate, Interactable where EntityType.GameType == GameType {
    
    var position: PositionComponent {
        return entity.position
    }
    var shape = ShapeComponent.rectangle(Size(0, 0)) {
        didSet {
            #if os(tvOS)
                node.size = CGSize(shape.size)
            #endif
        }
    }
    #if os(tvOS)
    private var node = InteractableNode()
    
    var focusItem: UIFocusItem {
        return node
    }
    #endif
    
    //MARK: Events
    var tap = WeakEvent<TapEvent>()
    #if os(tvOS)
    var focusUpdate = WeakEvent<FocusUpdateEvent>()
    #endif
    var isInteractable = true
    #if os(tvOS)
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        
        entity.addUpdatableComponent(updatable)
        
        
        entity.addNodeToScene(node, on: .gameplay, relatedToEntity: true)
        node.delegate = self
        node.interactable = self
    }
    #endif
    
    #if os(tvOS)
    func canBecomeFocused() -> Bool {
        return game?.interactionSystem.can(focus: self) ?? isInteractable
    }
    func didBecomeFocused() {
        focusUpdate.emit(FocusUpdateEvent(isFocused: true))
    }
    func willLostFocus() {
        focusUpdate.emit(FocusUpdateEvent(isFocused: false))
    }
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    
    let updateStep = UpdateStep.willRenderScene
    
    func updateWithDeltaTime(_ seconds: Scalar) {
        let position = CGPoint(entity.position)
        
        node.position = position
        
    }
    #endif
    
}
