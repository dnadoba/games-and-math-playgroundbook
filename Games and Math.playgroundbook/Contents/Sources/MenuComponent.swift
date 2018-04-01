//
//  MenuComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 28.07.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol MenuOption: EntityWithInteraction, EntityWithGame {
    func show()
    func hide()
}

final class MenuComponent<GameType: GameWithInteractionSystem, EntityType: EntityWithGame, OptionEntityType: MenuOption>: BasicComponentWithGame<GameType, EntityType>, FocusInterceptorDelegate where EntityType.GameType == GameType, OptionEntityType.GameType == GameType {
    
    var options: [OptionEntityType] = []
    
    var validInteractableTapTargets: [Interactable] = []
    
    let visibilityChange = WeakEvent<Bool>()
    let selected = WeakEvent<OptionEntityType>()
    
    fileprivate var isHidden = true {
        didSet {
            visibilityChange.emit(!isHidden)
        }
    }
    
    func show() {
        guard isHidden else {
            return
        }
        isHidden = false
        options.forEach { option in
            option.interaction.tap.on(self) { [unowned self] _ in
                self.selected.emit(option)
            }
            game?.addEntityWithGame(option)
            option.show()
        }
        
        game?.interactionSystem.tap.on(self) { [unowned self] event in
            
            let allValidInteractableTapTarget = self.validInteractableTapTargets + self.options.map { $0.interactable }
            let tappedOnValidTarget = allValidInteractableTapTarget.contains {
                $0 === event.interactable
            }
            if !tappedOnValidTarget {
                self.hide()
            }
        }
        game?.interactionSystem.focusInterceptorDelegate = self
        #if os(tvOS)
            game?.interactionSystem.setNeedsFocusUpdate()
        #endif
    }
    
    func hide() {
        guard !isHidden else {
            return
        }
        isHidden = true
        options.forEach {
            $0.interaction.tap.off(self)
            $0.hide()
            $0.removeFromGame()
        }
        self.game?.interactionSystem.tap.off(self)
    }
    #if os(tvOS)
    func can(focus interactable: Interactable) -> Bool? {
        guard !isHidden else {
            return nil
        }
        let interactables = options.map {
            return $0.interactable
        }
        return interactables.contains {
            return $0 === interactable
        }
    }
    #endif
}
