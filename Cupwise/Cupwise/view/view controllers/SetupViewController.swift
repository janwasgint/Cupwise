//
//  Copyright © 2018 Jan Wasgint. All rights reserved.
//

import Cocoa

class SetupViewController: NSViewController {
    @IBOutlet fileprivate weak var coffeeView: CoffeView!
    @IBOutlet fileprivate weak var loadingLabel: NSTextField!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        expenseManager.setup(success: {
            self.coffeeView.finish {
                switchFrom(currentViewController: self, toViewController: .configure)
            }
        }, failure: { _ in
            self.coffeeView.finish {
                switchFrom(currentViewController: self, toViewController: .login)
            }
        })
    }
}
