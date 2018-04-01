//
//  BasicGameController.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 18.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

public class BasicGameController: UIViewController {
    var game: Game?
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        game?.resume()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        game?.pause()
    }
}
