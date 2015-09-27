//
//  ViewController.swift
//  AHKBendableView
//
//  Created by Arkadiusz Holko on 26-06-14.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {

    @IBOutlet var bendableView: BendableView!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    @IBOutlet var widthConstraint: NSLayoutConstraint!
    @IBOutlet var heightConstraint: NSLayoutConstraint!

    @IBAction func randomizePositionTapped(sender: UIButton) {
        randomizePosition(true, randomizeSize: false)
    }

    @IBAction func randomizePositionAndSizeTapped(sender: UIButton) {
        randomizePosition(true, randomizeSize: true)
    }

    func randomizePosition(position: Bool, randomizeSize: Bool) {

        bendableView.damping = 0.7
        bendableView.initialSpringVelocity = 0.8

        if (randomizeSize) {
            widthConstraint.constant = CGFloat(UInt(arc4random_uniform(50)) + 150)
            heightConstraint.constant = CGFloat(UInt(arc4random_uniform(50)) + 150)
        }

        if (position) {
            // So many casts to satisfy the compiler...

            let maxTopMargin = UInt32(UInt(CGRectGetHeight(view.frame) - heightConstraint.constant))
            topConstraint.constant = CGFloat(UInt(arc4random_uniform(maxTopMargin)))

            let maxLeadingMargin = UInt32(UInt(CGRectGetWidth(view.frame) - widthConstraint.constant))
            leadingConstraint.constant = CGFloat(UInt(arc4random_uniform(maxLeadingMargin)))
        }

        UIView.animateWithDuration(0.5,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.9,
            options: [.BeginFromCurrentState, .AllowUserInteraction],
            animations: {
                self.view.layoutIfNeeded()
            }, completion: nil
        )

    }
}
