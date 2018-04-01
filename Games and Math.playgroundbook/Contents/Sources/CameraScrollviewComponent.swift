//
//  CameraComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 10.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import UIKit
import simd

class CameraScrollView: UIScrollView {
    
    
}

protocol UIScrollViewProxyDelegate: class {
    func viewForZoomingInScrollView(_ scrollView: UIScrollView) -> UIView?
}

class UIScrollViewProxyDelegateObject: NSObject, UIScrollViewDelegate {
    weak var delegate: UIScrollViewProxyDelegate?
    init(delegate: UIScrollViewProxyDelegate) {
        self.delegate = delegate
    }
    @objc func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return delegate?.viewForZoomingInScrollView(scrollView)
    }
}

protocol EntityWithCameraScrollView: EntityWithSKCameraNode, TransformableEntity, EntityWithUpdatableComponents, EntityWithLayoutableComponents {
    var scrollView: CameraScrollViewComponent<Self> { get }
}

final class CameraScrollViewComponent<EntityType: EntityWithSKCameraNode & TransformableEntity & EntityWithUpdatableComponents & EntityWithLayoutableComponents>: BasicComponent<EntityType>, UIScrollViewProxyDelegate, UpdatableComponent, LayoutableComponent {
    
    let scrollView: CameraScrollView = {
        let scrollView = CameraScrollView()
        // flip-y axis
        scrollView.transform = CGAffineTransform(scaleX: 1,y: -1);
        
        //scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        
        
        return scrollView
    }()
    
    lazy var proxyDelegate: UIScrollViewProxyDelegateObject = { [unowned self] in
        return UIScrollViewProxyDelegateObject(delegate: self)
    }()
    
    let zoomView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    override init() {
        super.init()
        
        scrollView.addSubview(contentView)
        //zoomView.addSubview(contentView)
        
        //Default
        bounces = false
        bouncesZoom = false
        
        scrollView.delegate = proxyDelegate
    }
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        
        entity.addUpdatableComponent(updatable)
        entity.addLayoutableComponent(self)
    }
    
    let updateStep = UpdateStep.willRenderScene
    
    fileprivate var zoomScaleNeedsUpdate: Bool = true
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        if zoomScaleNeedsUpdate {
            updateZoomScale()
        }
        
        if shouldZoomToMinimum {
            zoomToMinimum()
        }
        
        updateContentPosition()
        
        entity.position = contentOffset
        
        entity.scale = Vector(scale)
        
        entity.cameraNode.position.x = CGFloat(viewSize.width * 0.5)
        entity.cameraNode.position.y = CGFloat(viewSize.height * 0.5)
    }
    
    var bounces: Bool {
        get { return scrollView.bounces }
        set { scrollView.bounces = newValue }
    }
    var bouncesZoom: Bool {
        get { return scrollView.bouncesZoom }
        set { scrollView.bouncesZoom = newValue }
    }
    
    var minimumZoom: Scalar {
        if zoomScaleNeedsUpdate {
            updateZoomScale()
        }
        return Scalar(scrollView.minimumZoomScale)
    }
    
    var maximumZoom: Scalar {
        if zoomScaleNeedsUpdate {
            updateZoomScale()
        }
        return Scalar(scrollView.maximumZoomScale)
    }
    
    var zoom: Scalar {
        get {
            return Scalar(scrollViewZoomScale)
        }
        set(zoom) {
            scrollView.zoomScale = CGFloat(min(
                max(zoom, minimumZoom),
                maximumZoom
            ))
        }
    }
    
    var scale: Scalar {
        return 1/zoom
    }
    
    var viewSize = Size() {
        didSet {
            scrollView.frame.size = CGSize(viewSize)
            zoomScaleNeedsUpdate = true
        }
    }
    
    var contentSize = Size() {
        didSet {
            updateContentSize()
            zoomScaleNeedsUpdate = true
        }
    }
    
    var contentInset = EdgeInsets() {
        didSet {
            updateContentSize()
            updateContentPosition()
            zoomScaleNeedsUpdate = true
        }
    }
    
    fileprivate var realContentSize: Size {
        return Size(
            contentSize.width + Scalar(contentInset.left + contentInset.right),
            contentSize.height + Scalar(contentInset.top + contentInset.bottom)
        )
    }
    
    fileprivate func updateContentPosition() {
        //contentView.frame.origin.x = contentInset.left
        //contentView.frame.origin.y = contentInset.bottom
    }
    
    fileprivate func updateContentSize() {
        let zoomScale = scrollView.zoomScale
        scrollView.zoomScale = 1
        scrollView.contentSize = CGSize(realContentSize)
        
        //zoomView.frame.size = CGSize(realContentSize)
        contentView.frame.size = CGSize(realContentSize)
        scrollView.zoomScale = zoomScale
    }
    
    fileprivate func updateZoomScale() {
        zoomScaleNeedsUpdate = false
        let minZoom = minimumZoomToDisplayContent(realContentSize)
        scrollView.minimumZoomScale = CGFloat(minZoom)
        scrollView.maximumZoomScale = CGFloat(max(minZoom, 1))
        scrollView.zoomScale = min(
            max(scrollView.minimumZoomScale, scrollView.zoomScale),
            scrollView.maximumZoomScale
        )
    }
    
    fileprivate var scrollViewOffset: Vector {
        guard let presentationLayer = scrollView.layer.presentation() else {
            return Vector(scrollView.contentOffset)
        }
        return Vector(presentationLayer.bounds.origin)
    }
    
    fileprivate var scrollViewZoomScale: Scalar {
        guard let zoomView = scrollView.delegate?.viewForZooming?(in: self.scrollView),
            let presentationLayer = zoomView.layer.presentation() else {
            return Scalar(scrollView.zoomScale)
        }
        return Scalar(presentationLayer.transform.m11)
    }
    
    fileprivate var contentOffset: Vector {
        
        
        var offset = scrollViewOffset
        offset *= scale
        offset.x -= Scalar(contentInset.left)
        offset.y -= Scalar(contentInset.bottom)
        //offset *= scale
        //offset.x -= Scalar(contentInset.left)
        //offset.y -= Scalar(contentInset.top)
        
        //print("offset", offset)
        //print("contentOffset", scrollView.contentOffset)
        //print("contentInset", contentInset)
        //print("scale", scale)
        
        /*
        
        // old flip-y axis implemntaiton
        var v = Vector(0,0)
        v.y = contentSize.height - (viewSize.height * scale)
        v.y -= offset.y
        v.x += offset.x
        */

        return offset
    }
    
    func viewForZoomingInScrollView(_ scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    func layout(_ viewSize: Size) {
        self.viewSize = viewSize
    }
    
    fileprivate func minimumZoomToDisplayContent(_ contentSize: Size) -> Scalar {
        let zoomToDisplayFullContent = viewSize / contentSize
        return max(zoomToDisplayFullContent.width, zoomToDisplayFullContent.height)
    }
    
    fileprivate var shouldZoomToMinimum = false
    
    func zoomOut() {
        shouldZoomToMinimum = true
    }
    
    fileprivate func zoomToMinimum() {
        shouldZoomToMinimum = false
        zoom = minimumZoom
    }
}
