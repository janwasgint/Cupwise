//
//  Copyright © 2018 Jan Wasgint. All rights reserved.
//

import Cocoa

class ConfigureViewController: NSViewController {
    fileprivate let preferredGroupName = "Quartett mobile"
    fileprivate let preferredCoffeeAccountName = "El Cappuccino"
    
    @IBOutlet fileprivate weak var currencyPopUpButton: NSPopUpButton!
    @IBOutlet fileprivate weak var coffeeAccountPopupButton: NSPopUpButton!
    @IBOutlet fileprivate weak var nameLabel: NSTextField! {
        didSet {
            nameLabel.stringValue = expenseManager.currentUser()?.name ?? ""
        }
    }
    @IBOutlet fileprivate weak var groupPopUpButton: NSPopUpButton! {
        didSet {
            update(popUpButton: groupPopUpButton, newItems: expenseManager.groups(), preferredItem: preferredGroupName)
        }
    }
    @IBOutlet fileprivate weak var priceTextField: NSTextField! {
        didSet {
            priceTextField.stringValue = "\(String(format: "%.2f", expenseManager.coffeePrice))"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCurrencyPopUpButtonItems()
        updateCoffeAccountPopUpButtonItems()
    }
    
    @IBAction fileprivate func saveButtonPressed(_ sender: Any) {
        if let price = Double(priceTextField.stringValue), price > 0,
            let coffeeGroupName = groupPopUpButton.selectedItem?.title,
            let coffeeAccountName = coffeeAccountPopupButton.selectedItem?.title {
            
            expenseManager.coffeePrice = price.roundedWithTwoDecimalPlaces()
            expenseManager.coffeeGroupId = expenseManager.idFor(group: coffeeGroupName)
            expenseManager.coffeeAccountId = expenseManager.membersFor(group: coffeeGroupName).reduce(-1) { $1.0 == coffeeAccountName ? $1.1 : $0 }
            
            switchFrom(currentViewController: self, toViewController: .coffee)
        } else {
            priceTextField.stringValue = "\(expenseManager.coffeePrice)"
        }
    }
    
    @IBAction fileprivate func didSelectGroup(_ sender: Any) {
        updateCurrencyPopUpButtonItems()
        updateCoffeAccountPopUpButtonItems()
    }
    
    fileprivate func updateCoffeAccountPopUpButtonItems() {
        let selectedGroup = groupPopUpButton.selectedItem?.title ?? ""
        let selectedGroupMembers = expenseManager.membersFor(group: selectedGroup).map { $0.0 }
        update(popUpButton: coffeeAccountPopupButton, newItems: selectedGroupMembers, preferredItem: preferredCoffeeAccountName)
    }
    
    fileprivate func updateCurrencyPopUpButtonItems() {
        let selectedGroup = groupPopUpButton.selectedItem?.title ?? ""
        let selectedGroupCurrencies = expenseManager.currenciesFor(group: selectedGroup)
        let defaultCurrency = expenseManager.currentUser()?.defaultCurrency ?? ""
        update(popUpButton: currencyPopUpButton, newItems: selectedGroupCurrencies, preferredItem: defaultCurrency)
    }
    
    fileprivate func update(popUpButton: NSPopUpButton, newItems: [String], preferredItem: String) {
        popUpButton.removeAllItems()
        popUpButton.addItems(withTitles: newItems)
        if (newItems.contains { $0 == preferredItem}) {
            popUpButton.selectItem(withTitle: preferredItem)
        }
    }
}
