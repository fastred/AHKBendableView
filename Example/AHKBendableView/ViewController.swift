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

    @IBAction func randomizePositionTapped(_ sender: UIButton) {
        randomizePosition(true, randomizeSize: false)
    }

    @IBAction func randomizePositionAndSizeTapped(_ sender: UIButton) {
        randomizePosition(true, randomizeSize: true)
    }

    func randomizePosition(_ position: Bool, randomizeSize: Bool) {

        bendableView.damping = 0.7
        bendableView.initialSpringVelocity = 0.8

        if (randomizeSize) {
            widthConstraint.constant = CGFloat(arc4random_uniform(50)) + 150
            heightConstraint.constant = CGFloat(arc4random_uniform(50)) + 150
        }

        if (position) {
            let maxTopMargin = view.frame.height - heightConstraint.constant
            topConstraint.constant = CGFloat(arc4random_uniform(UInt32(maxTopMargin)))

            let maxLeadingMargin = view.frame.width - widthConstraint.constant
            leadingConstraint.constant = CGFloat(arc4random_uniform(UInt32(maxLeadingMargin)))
        }

        UIView.animate(withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.9,
            options: [.beginFromCurrentState, .allowUserInteraction],
            animations: {
                self.view.layoutIfNeeded()
            }, completion: nil
        )

    }
}
