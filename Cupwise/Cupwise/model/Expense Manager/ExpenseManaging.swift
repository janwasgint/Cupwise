//
//  Copyright © 2018 Jan Wasgint. All rights reserved.
//

import Foundation

protocol ExpenseManaging {
    var coffeePrice: Double { get set }
    var coffeeGroupId: Int? { get set }
    var coffeeAccountId: Int? { get set }
    
    func logIn(success: @escaping () -> Void, failure: @escaping (String) -> Void)
    func setup(success: @escaping () -> Void, failure: @escaping (String) -> Void)
    func currentUser() -> User?
    func groups() -> [String]
    func idFor(group: String) -> Int?
    func membersFor(group: String) -> [(String, Int)]
    func currenciesFor(group: String) -> [String]
    func addCoffeeExpense(numberOfCoffees: Int, success: @escaping () -> Void)
}
