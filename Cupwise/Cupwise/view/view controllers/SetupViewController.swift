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
                let previousCoffeePrice = UserDefaults.standard.double(forKey: "coffeePrice")
                let previousCoffeeGroupId = UserDefaults.standard.integer(forKey: "coffeeGroupId")
                let previousCoffeeAccountId = UserDefaults.standard.integer(forKey: "coffeeAccountId")
                
                if let previousCoffeeGroup = expenseManager.groups().filter({ $0.id == previousCoffeeGroupId}).first,
                    previousCoffeeGroup.members.contains(where: { $0.id == previousCoffeeAccountId}) {
                    expenseManager.coffeePrice = previousCoffeePrice
                    expenseManager.coffeeGroupId = previousCoffeeGroupId
                    expenseManager.coffeeAccountId = previousCoffeeAccountId
                    switchFrom(currentViewController: self, toViewController: .coffee)
                } else {
                    switchFrom(currentViewController: self, toViewController: .configure)
                }
            }
        }, failure: { _ in
            self.coffeeView.finish {
                switchFrom(currentViewController: self, toViewController: .login)
            }
        })
    }
}
