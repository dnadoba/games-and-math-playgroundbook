//
//  ContentSizeConstraintComponent
//  EntityComponentSystemMacOS
//
//  Created by David Nadoba on 21.03.18.
//  Copyright © 2018 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

fileprivate struct ContentSizeConstrains {
    var maxWidth: NSLayoutConstraint
    var maxHeight: NSLayoutConstraint
    
    init(for view: SKView) {
        maxWidth = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .width, multiplier: 1, constant: 1000)
        maxHeight = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: 1000)
    }
}

extension ContentSizeConstrains {
    func update(for contentSize: Size) {
        maxWidth.constant = CGFloat(contentSize.width)
        maxHeight.constant = CGFloat(contentSize.height)
    }
}

class ContentSizeConstraintComponent: Component {
    var view: SKView? {
        didSet {
            guard view != oldValue else { return }
            NSLayoutConstraint.deactivate(allConstrains)
            guard let view = view else { return }
            makeAndActivateAllConstrains(for: view)
        }
    }
    
    var contentSize = Size() {
        didSet {
            updateConstrains()
        }
    }
    
    private var aspectConstraint: NSLayoutConstraint?
    private var sizeConstraints: ContentSizeConstrains?
    private var allConstrains: [NSLayoutConstraint] {
        return [aspectConstraint, sizeConstraints?.maxWidth, sizeConstraints?.maxHeight].flatMap { $0 }
    }
    
    private func makeAndActivateAllConstrains(for view: SKView) {
        self.sizeConstraints = makeSizeConstraints(for: view)
        self.aspectConstraint = makeAspectConstraint(for: view)
        NSLayoutConstraint.activate(allConstrains)
    }
    
    private func makeSizeConstraints(for view: SKView) -> ContentSizeConstrains {
        
        let sizeConstraints = ContentSizeConstrains(for: view)
        sizeConstraints.update(for: contentSize)
        return sizeConstraints
    }
    
    private func makeAspectConstraint(for view: SKView) -> NSLayoutConstraint {
        return NSLayoutConstraint(
            item: view,
            attribute: .width,
            relatedBy: .equal,
            toItem: view,
            attribute: .height,
            //aspect ratio
            multiplier: CGFloat(contentSize.width/contentSize.height),
            constant: 0
        )
    }
    
    private func updateConstrains() {
        guard let view = view else { return }
        self.aspectConstraint.flatMap{ NSLayoutConstraint.deactivate([$0]) }
        let aspectConstraint = makeAspectConstraint(for: view)
        NSLayoutConstraint.activate([aspectConstraint])
        self.aspectConstraint = aspectConstraint
        sizeConstraints?.update(for: contentSize)
    }
}
