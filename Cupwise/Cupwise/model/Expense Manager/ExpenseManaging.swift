//
//  Copyright © 2018 Jan Wasgint. All rights reserved.
//

import Foundation

protocol ExpenseManaging {
    var coffeePrice: Double { get set }
    var coffeeGroupId: Int? { get set }
    var coffeeAccountId: Int? { get set }
    
    func loggedIn() -> Bool
    func logIn(success: @escaping () -> Void, failure: @escaping (String) -> Void)
    func setup(success: @escaping () -> Void, failure: @escaping (String) -> Void)
    func currentUser() -> User?
    func groups() -> [Group]
    func addCoffeeExpense(numberOfCoffees: Int, success: @escaping () -> Void)
}
