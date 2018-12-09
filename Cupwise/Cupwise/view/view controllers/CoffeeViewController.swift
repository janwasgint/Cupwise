//
//  Copyright © 2018 Jan Wasgint. All rights reserved.
//

import Cocoa

class CoffeeViewController: NSViewController {
    @IBOutlet fileprivate weak var coffeeView: CoffeView!
    @IBOutlet fileprivate weak var progressIndicator: CircleProgressView!
    @IBOutlet fileprivate weak var addCoffeesButton: NSButton!
    @IBOutlet fileprivate weak var plusButton: NSButton!
    @IBOutlet fileprivate weak var showExpenseButton: NSButton! {
        didSet {
            showExpenseButton.isHidden = true
        }
    }
    @IBOutlet fileprivate weak var numberOfCoffeesTextField: NSTextField! {
        didSet {
            numberOfCoffeesTextField.stringValue = "1"
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.makeFirstResponder(addCoffeesButton)
    }
    
    @IBAction fileprivate func addCoffeesButtonPressed(_ sender: Any) {
        if let numberOfCoffees = Int(numberOfCoffeesTextField.stringValue) {
            startLoading()
            expenseManager.addCoffeeExpense(numberOfCoffees: numberOfCoffees, success: {
                self.stopLoading()
            })
        }
    }
    
    @IBAction fileprivate func infoButtonPressed(_ sender: Any) {
        switchFrom(currentViewController: self, toViewController: .credits)
    }
    
    @IBAction fileprivate func configureButtonPressed(_ sender: Any) {
        switchFrom(currentViewController: self, toViewController: .configure)
    }

    @IBAction fileprivate func plusButtonPressed(_ sender: Any) {
        if let numberOfCoffees = Int(numberOfCoffeesTextField.stringValue) {
            numberOfCoffeesTextField.stringValue = "\(numberOfCoffees + 1)"
        } else {
            numberOfCoffeesTextField.stringValue = "1"
        }
    }
    
    @IBAction fileprivate func minusButtonPressed(_ sender: Any) {
        if let numberOfCoffees = Int(numberOfCoffeesTextField.stringValue), numberOfCoffees > 1 {
            numberOfCoffeesTextField.stringValue = "\(numberOfCoffees - 1)"
        } else {
            numberOfCoffeesTextField.stringValue = "1"
        }
    }
    
    @IBAction func showExpensButtonPressed(_ sender: Any) {
        if let groupID = expenseManager.coffeeGroupId,
            let groupURL = URL(string: "https://secure.splitwise.com/#/groups/\(groupID)") {
            setClosesOnPressOutsidePopover(false)
            NSWorkspace.shared.open(groupURL)
            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
                setClosesOnPressOutsidePopover(true)
            })
            showExpenseButton.fadeOut(duration: 0.5) {
                self.showExpenseButton.isHidden = true
            }
        }
    }
    
    fileprivate func startLoading() {
        progressIndicator.startAnimation()
        addCoffeesButton.isEnabled = false
        view.window?.makeFirstResponder(plusButton)
        coffeeView.fadeOut(duration: 0.5)
        if !showExpenseButton.isHidden {
            showExpenseButton.fadeOut(duration: 0.5) {
                self.showExpenseButton.isHidden = true
            }
        }
    }
    
    fileprivate func stopLoading() {
        self.showExpenseButton.isHidden = false
        self.showExpenseButton.fadeIn(duration: 0.5)
        progressIndicator.stopAnimation() {
            self.addCoffeesButton.isEnabled = true
            self.coffeeView.fadeIn(duration: 0.5)
        }
    }
}
