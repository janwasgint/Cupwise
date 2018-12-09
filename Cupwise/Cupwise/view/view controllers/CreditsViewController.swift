//
//  Copyright © 2018 Jan Wasgint. All rights reserved.
//

import Cocoa

class CreditsViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        switchFrom(currentViewController: self, toViewController: .coffee)
    }
}
