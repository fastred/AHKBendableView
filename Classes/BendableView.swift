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

    override func addAnimation(anim: CAAnimation, forKey key: String?) {
        super.addAnimation(anim, forKey: key)

        // Checks if the animation changes the position and lets the view know about that.
        if let basicAnimation = anim as? CABasicAnimation {
            if basicAnimation.keyPath == NSStringFromSelector("position") {
                self.delegate?.positionAnimationWillStart?(basicAnimation)
            }
        }
    }
}

private protocol BendableLayerDelegate {
    func positionAnimationWillStart(anim: CABasicAnimation)
}


/// UIView subclass that bends its edges (internally, a CAShapeLayer filled with `fillColor`) when its position changes.
///
/// You'll receive the best effect when you use `+animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:`
/// to animate the change of the position and set `damping` and `initialSpringVelocity` to different values
/// than in that animation call. I propose to use slightly lower values for these properties.
/// These properties can't be set automatically, because `CASpringAnimation` is private.
public class BendableView: UIView, BendableLayerDelegate {

    public var damping: CGFloat = 0.7
    public var initialSpringVelocity: CGFloat = 0.8
    public var fillColor: UIColor = UIColor(red: 0, green: 0.722, blue: 1, alpha: 1) {
    didSet {
        updateColor()
    }
    }

    private var displayLink: CADisplayLink?
    private var animationCount = 0
    // A hidden view that is used only for spring animation's simulation.
    // Its frame's origin matches the view's frame origin (except during animation). Of course it is in a different coordinate system,
    // but it doesn't matter to us. What we're interested in, is a position's difference between this subview's frame and the view's frame.
    // This difference (`bendableOffset`) is used for "bending" the edges of the view.
    private let dummyView = UIView()
    private let shapeLayer = CAShapeLayer()
    private var bendableOffset: UIOffset = UIOffsetZero {
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

    private func commonInit() {
        self.layer.insertSublayer(shapeLayer, atIndex: 0)
        updatePath()
        updateColor()

        addSubview(dummyView)
    }

    // MARK: UIView

    override public class func layerClass() -> AnyClass {
        return BendableLayer.self
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        updatePath()
        dummyView.frame.origin = frame.origin
    }

    // MARK: BendableLayerDelegate

    func positionAnimationWillStart(anim: CABasicAnimation) {
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: "tick:")
            displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        }
        animationCount++

        let newPosition = layer.frame.origin

        // Effects of this animation are invisible, because dummyView is hidden.
        // dummyView frame's change animation matches the animation of the whole view, though it's in a different coordinate system.
        UIView.animateWithDuration(anim.duration,
            delay: anim.beginTime,
            usingSpringWithDamping: damping,
            initialSpringVelocity: initialSpringVelocity,
            options: [.BeginFromCurrentState, .AllowUserInteraction, .OverrideInheritedOptions],
            animations: {
                self.dummyView.frame.origin = newPosition
            }, completion: { _ in
                self.animationCount--
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
        if let presentationLayer = layer.presentationLayer() as? CALayer {
            bounds = presentationLayer.bounds
        } else {
            bounds = self.bounds
        }

        let width = CGRectGetWidth(bounds)
        let height = CGRectGetHeight(bounds)

        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addQuadCurveToPoint(CGPoint(x: width, y: 0),
            controlPoint:CGPoint(x: width / 2.0, y: 0 + bendableOffset.vertical))
        path.addQuadCurveToPoint(CGPoint(x: width, y: height),
            controlPoint:CGPoint(x: width + bendableOffset.horizontal, y: height / 2.0))
        path.addQuadCurveToPoint(CGPoint(x: 0, y: height),
            controlPoint: CGPoint(x: width / 2.0, y: height + bendableOffset.vertical))
        path.addQuadCurveToPoint(CGPoint(x: 0, y: 0),
            controlPoint: CGPoint(x: bendableOffset.horizontal, y: height / 2.0))
        path.closePath()

        shapeLayer.path = path.CGPath
    }

    func updateColor() {
        shapeLayer.fillColor = fillColor.CGColor
    }

    func tick(displayLink: CADisplayLink) {
        if let dummyViewPresentationLayer = dummyView.layer.presentationLayer() as? CALayer {
            if let presentationLayer = layer.presentationLayer() as? CALayer {
                bendableOffset = UIOffset(horizontal: CGRectGetMinX(dummyViewPresentationLayer.frame) - CGRectGetMinX(presentationLayer.frame),
                    vertical: CGRectGetMinY(dummyViewPresentationLayer.frame) - CGRectGetMinY(presentationLayer.frame))
            }
        }
    }
}
