//
//  Copyright © 2018 Jan Wasgint. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController {
    @IBOutlet fileprivate weak var circleProgressViewTopConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var circleProgressView: CircleProgressView!
    @IBOutlet fileprivate weak var loginButton: NSButton!
    @IBOutlet fileprivate weak var errorLabel: NSTextField!
    
    @IBAction fileprivate func logInButtonPressed(_ sender: Any) {
        circleProgressView.startAnimation()
        loginButton.isEnabled = false
        errorLabel.isHidden = true
        
        expenseManager.logIn(success: {
            self.loginButton.fadeOut(duration: 0.5)
            NSView.animate(duration: 0.5, animations: {
                self.circleProgressViewTopConstraint.animator().constant = (self.view.frame.height - self.circleProgressView.frame.height) * 0.5
            })
            
            self.circleProgressView.stopAnimation() {
                switchFrom(currentViewController: self, toViewController: .setup)
            }
        }, failure: { errorMessage in
            self.circleProgressView.reset {
                self.errorLabel.isHidden = false
                self.errorLabel.stringValue = "Error: \(errorMessage)"
                self.loginButton.isEnabled = true
            }
        })
    }
}
