//
//  ViewController.swift
//  BouncyView
//
//  Created by Arkadiusz on 26-06-14.
//  Copyright (c) 2014 Arkadiusz Holko. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {

    @IBOutlet var bouncyView: BouncyView
    @IBOutlet var topConstraint: NSLayoutConstraint
    @IBOutlet var leadingConstraint: NSLayoutConstraint
    @IBOutlet var widthConstraint: NSLayoutConstraint
    @IBOutlet var heightConstraint: NSLayoutConstraint

    @IBAction func toggleVisibility(sender: UIButton) {

        bouncyView.damping = 0.7
        bouncyView.initialSpringVelocity = 0.8

        widthConstraint.constant = CGFloat(arc4random() % 50) + 150
        heightConstraint.constant = CGFloat(arc4random() % 50) + 150

        if (arc4random() % 2 == 0) {
            topConstraint.constant = CGFloat(arc4random() % UInt32(CGRectGetHeight(view.frame) - heightConstraint.constant))
        } else {
            leadingConstraint.constant = CGFloat(arc4random() % UInt32(CGRectGetWidth(view.frame) - widthConstraint.constant))
        }

        UIView.animateWithDuration(0.5,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.9,
            options: .BeginFromCurrentState | .AllowUserInteraction,
            animations: {
                self.bouncyView.layoutIfNeeded()
            }, completion: nil
        )
    }
}
