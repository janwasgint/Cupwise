//
//  Copyright © 2018 Jan Wasgint. All rights reserved.
//

import Foundation

class MockExpenseManager: ExpenseManaging {
    var coffeePrice: Double = 0.5
    var coffeeGroupId: Int? = nil
    var coffeeAccountId: Int? = nil
    
    func idFor(group: String) -> Int? {
        return -1
    }
    
    func currentUser() -> User? {
        return User(id: 0, firstName: "Mock", lastName: "User", email: "mock.user@mockmail.com", defaultCurrency: "MOCK")
    }
    
    func loggedIn() -> Bool {
        return false
    }
    
    func logIn(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        print("Logging In ...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: success)
    }
    
    func setup(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        print("Setting Up ...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: success)
    }
    
    func groups() -> [String] {
        return ["MockGroup A", "MockGroup B"]
    }
    
    func membersFor(group: String) -> [(String, Int)] {
        return [("Mock MemberA", 1), ("Mock MemberB", 2)]
    }
    
    func currenciesFor(group: String) -> [String] {
        return ["MOCK"]
    }
    
    func addCoffeeExpense(numberOfCoffees: Int, success: @escaping () -> Void) {
        print("Adding ... \(numberOfCoffees) Coffees")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: success)
    }
}
