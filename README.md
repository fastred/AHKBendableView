# AHKBendableView

[![CocoaPods](https://img.shields.io/cocoapods/v/BendableView.svg?style=flat)](https://github.com/fastred/BendableView)

`AHKBendableView` is a `UIView` subclass that bends its edges when its position change is animated. If you're interested to know how it works, you should read: [Recreating Skype's Action Sheet Animation](http://holko.pl/2014/06/26/recreating-skypes-action-sheet-animation/) and a [follow-up post](http://holko.pl/2014/06/28/action-sheet-follow-up/).

![Demo GIF](https://raw.githubusercontent.com/fastred/AHKBendableView/master/demo.gif)

## Usage

Use a `BendableView` directly or subclass it. Don't forget to set its internal spring parameters. I propose to use slightly lower values for these properties than the values used in `+animateWithDuration:delay:usingSpringWithDamping:
initialSpringVelocity:options:animations:completion:`, just like in this example:

    let bv = BendableView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    view.addSubview(bv)

    // bending setup
    bv.fillColor = UIColor.redColor()
    bv.damping = 0.7 // used to animate the view's edges
    bv.initialSpringVelocity = 0.8 // used to animate the view's edges

    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: .BeginFromCurrentState | .AllowUserInteraction, animations: {
            bv.frame.origin = CGPoint(x: 200, y: 300)
            bv.frame.size = CGSize(width: 150, height: 150)
        }, completion: nil)


## Example project

To run the example project, clone the repo, and open `Example/AHKBendableView.xcodeproj`.

## Requirements

- iOS 7.0
- ARC

## Installation

AHKBendableView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "AHKBendableView"

## Author

Arkadiusz Holko, [See my blog](http://holko.pl/) and feel free to [follow me on Twitter](https://twitter.com/arekholko).

## License

AHKBendableView is available under the MIT license. See the LICENSE file for more info.

