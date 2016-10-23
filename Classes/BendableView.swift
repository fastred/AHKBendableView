//
//  BendableView.swift
//  AHKBendableView
//
//  Created by Arkadiusz Holko on 26-06-14.
//

import UIKit
import CoreGraphics
import QuartzCore

private class BendableLayer: CALayer {

    override func add(_ anim: CAAnimation, forKey key: String?) {
        super.add(anim, forKey: key)

        // Checks if the animation changes the position and lets the view know about that.
        if let basicAnimation = anim as? CABasicAnimation {
            if basicAnimation.keyPath == NSStringFromSelector(#selector(getter: CALayer.position)) {
                if let delegate = delegate as? BendableLayerDelegate {
                    delegate.positionAnimationWillStart(basicAnimation)
                }
            }
        }
    }
}

private protocol BendableLayerDelegate {
    func positionAnimationWillStart(_ anim: CABasicAnimation)
}


/// UIView subclass that bends its edges (internally, a CAShapeLayer filled with `fillColor`) when its position changes.
///
/// You'll receive the best effect when you use `+animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:`
/// to animate the change of the position and set `damping` and `initialSpringVelocity` to different values
/// than in that animation call. I propose to use slightly lower values for these properties.
/// These properties can't be set automatically, because `CASpringAnimation` is private.
open class BendableView: UIView, BendableLayerDelegate {

    open var damping: CGFloat = 0.7
    open var initialSpringVelocity: CGFloat = 0.8
    open var fillColor: UIColor = UIColor(red: 0, green: 0.722, blue: 1, alpha: 1) {
    didSet {
        updateColor()
    }
    }

    fileprivate var displayLink: CADisplayLink?
    fileprivate var animationCount = 0
    // A hidden view that is used only for spring animation's simulation.
    // Its frame's origin matches the view's frame origin (except during animation). Of course it is in a different coordinate system,
    // but it doesn't matter to us. What we're interested in, is a position's difference between this subview's frame and the view's frame.
    // This difference (`bendableOffset`) is used for "bending" the edges of the view.
    fileprivate let dummyView = UIView()
    fileprivate let shapeLayer = CAShapeLayer()
    fileprivate var bendableOffset: UIOffset = UIOffset.zero {
        didSet {
            updatePath()
        }
    }

    // MARK: Init

    override public init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    fileprivate func commonInit() {
        layer.insertSublayer(shapeLayer, at: 0)
        updatePath()
        updateColor()

        addSubview(dummyView)
    }

    // MARK: UIView

    override open class var layerClass : AnyClass {
        return BendableLayer.self
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        updatePath()
        dummyView.frame.origin = frame.origin
    }

    // MARK: BendableLayerDelegate

    func positionAnimationWillStart(_ anim: CABasicAnimation) {
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(tick(_:)))
            displayLink!.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        }
        animationCount += 1

        let newPosition = layer.frame.origin

        // Effects of this animation are invisible, because dummyView is hidden.
        // dummyView frame's change animation matches the animation of the whole view, though it's in a different coordinate system.
        UIView.animate(withDuration: anim.duration,
            delay: anim.beginTime,
            usingSpringWithDamping: damping,
            initialSpringVelocity: initialSpringVelocity,
            options: [.beginFromCurrentState, .allowUserInteraction, .overrideInheritedOptions],
            animations: {
                self.dummyView.frame.origin = newPosition
            }, completion: { _ in
                self.animationCount -= 1
                if self.animationCount == 0 {
                    self.displayLink!.invalidate()
                    self.displayLink = nil
                }
            }
        )
    }

    // MARK: Internal

    func updatePath() {
        var bounds: CGRect
        if let presentationLayer = layer.presentation() {
            bounds = presentationLayer.bounds
        } else {
            bounds = self.bounds
        }

        let width = bounds.width
        let height = bounds.height

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addQuadCurve(to: CGPoint(x: width, y: 0),
            controlPoint:CGPoint(x: width / 2.0, y: 0 + bendableOffset.vertical))
        path.addQuadCurve(to: CGPoint(x: width, y: height),
            controlPoint:CGPoint(x: width + bendableOffset.horizontal, y: height / 2.0))
        path.addQuadCurve(to: CGPoint(x: 0, y: height),
            controlPoint: CGPoint(x: width / 2.0, y: height + bendableOffset.vertical))
        path.addQuadCurve(to: CGPoint(x: 0, y: 0),
            controlPoint: CGPoint(x: bendableOffset.horizontal, y: height / 2.0))
        path.close()

        shapeLayer.path = path.cgPath
    }

    func updateColor() {
        shapeLayer.fillColor = fillColor.cgColor
    }

    func tick(_ displayLink: CADisplayLink) {
        if let dummyViewPresentationLayer = dummyView.layer.presentation() {
            if let presentationLayer = layer.presentation() {
                bendableOffset = UIOffset(horizontal: (dummyViewPresentationLayer.frame).minX - (presentationLayer.frame).minX,
                    vertical: (dummyViewPresentationLayer.frame).minY - (presentationLayer.frame).minY)
            }
        }
    }
}
