//
//  ViewController.swift
//  AHKBendableView
//
//  Created by Arkadiusz on 26-06-14.
//  Copyright (c) 2014 Arkadiusz Holko. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {

    @IBOutlet var bendableView: BendableView
    @IBOutlet var topConstraint: NSLayoutConstraint
    @IBOutlet var leadingConstraint: NSLayoutConstraint
    @IBOutlet var widthConstraint: NSLayoutConstraint
    @IBOutlet var heightConstraint: NSLayoutConstraint

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
            widthConstraint.constant = CGFloat(arc4random() % 50) + 150
            heightConstraint.constant = CGFloat(arc4random() % 50) + 150
        }

        if (position) {
            topConstraint.constant = CGFloat(arc4random() % UInt32(CGRectGetHeight(view.frame) - heightConstraint.constant))
            leadingConstraint.constant = CGFloat(arc4random() % UInt32(CGRectGetWidth(view.frame) - widthConstraint.constant))
        }

        UIView.animateWithDuration(0.5,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.9,
            options: .BeginFromCurrentState | .AllowUserInteraction,
            animations: {
                self.view.layoutIfNeeded()
            }, completion: nil
        )

    }
}
