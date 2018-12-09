//
//  Copyright © 2018 Jan Wasgint. All rights reserved.
//

import Cocoa

class CoffeView: NSView {
    fileprivate var cupImageView: NSImageView?
    fileprivate var steamImageView: NSImageView?
    fileprivate var repeatsAnimation = true
    fileprivate var steamImageViewTopConstraint: NSLayoutConstraint?
    fileprivate var completion: (() -> Void)?
    fileprivate var heightConstraintAnchor: CGFloat = 0
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initializeImages()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        initializeImages()
    }
    
    func finish(completion: @escaping () -> Void) {
        repeatsAnimation = false
        self.completion = completion
    }
    
    fileprivate func initializeImages() {
        if cupImageView == nil || steamImageView == nil {
            let cupImageView = NSImageView(frame: frame)
            let steamImageView = NSImageView(frame: frame)
            
            pin(subview: cupImageView)
            pin(subview: steamImageView)
            
            cupImageView.image = NSImage(named: "cup")
            steamImageView.image = NSImage(named: "steam")
            
            self.cupImageView = cupImageView
            self.steamImageView = steamImageView
            
            for constraint in constraints {
                if constraint.firstAnchor == steamImageView.topAnchor || constraint.secondAnchor == steamImageView.topAnchor {
                    steamImageViewTopConstraint = constraint
                    heightConstraintAnchor = constraint.constant
                }
            }
            
            fadeInSteam()
        }
    }
    
    fileprivate func fadeInSteam() {
        steamImageView?.alphaValue = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            NSView.animate(duration: 0.5, animations: {
                self.steamImageView?.animator().alphaValue = 1.0
                self.steamImageViewTopConstraint?.animator().constant = self.heightConstraintAnchor + 3
            }) {
                self.moveSteamup()
            }
        })
    }
    
    fileprivate func moveSteamup() {
        NSView.animate(duration: 1, animations: {
            steamImageViewTopConstraint?.animator().constant = self.heightConstraintAnchor + 7
        }) {
            self.fadeOutSteam()
        }
    }
    
    fileprivate func fadeOutSteam() {
        NSView.animate(duration: 0.5, animations: {
            steamImageView?.animator().alphaValue = 0.0
            steamImageViewTopConstraint?.animator().constant = self.heightConstraintAnchor + 10
        }) {
            if self.repeatsAnimation {
                self.steamImageViewTopConstraint?.constant = self.heightConstraintAnchor
                self.fadeInSteam()
            } else {
                self.completion?()
            }
        }
    }
}
