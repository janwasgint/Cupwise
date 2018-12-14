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
            update(popUpButton: groupPopUpButton, newItems: expenseManager.groups().map { $0.name }, preferredItem: preferredGroupName)
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
            let coffeeAccountName = coffeeAccountPopupButton.selectedItem?.title,
            let coffeeGroup = expenseManager.groups().reduce(nil, { (accumulator: Group?, group: Group) -> Group? in group.name == coffeeGroupName ? group : accumulator }) {
            
            expenseManager.coffeePrice = price.roundedWithTwoDecimalPlaces()
            expenseManager.coffeeGroupId = coffeeGroup.id
            expenseManager.coffeeAccountId = coffeeGroup.members.filter { $0.name == coffeeAccountName }.first?.id
            
            if expenseManager.coffeeAccountId != nil {
                UserDefaults.standard.set(expenseManager.coffeePrice, forKey: "coffeePrice")
                UserDefaults.standard.set(expenseManager.coffeeGroupId, forKey: "coffeeGroupId")
                UserDefaults.standard.set(expenseManager.coffeeAccountId, forKey: "coffeeAccountId")
            }
            
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
        let selectedGroupMembers = expenseManager.groups().reduce([]) { $1.name == selectedGroup ? $1.members : $0}
        update(popUpButton: coffeeAccountPopupButton, newItems: selectedGroupMembers.map { $0.name }, preferredItem: preferredCoffeeAccountName)
    }
    
    fileprivate func updateCurrencyPopUpButtonItems() {
        let selectedGroup = groupPopUpButton.selectedItem?.title ?? ""
        let selectedGroupCurrencies = expenseManager.groups().reduce([]) { $1.name == selectedGroup ? $1.currencies : $0}
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
