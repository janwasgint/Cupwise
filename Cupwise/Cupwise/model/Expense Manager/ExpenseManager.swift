//
//  Copyright © 2018 Jan Wasgint. All rights reserved.
//

import OAuthSwift
import SwiftyJSON

class ExpenseManager: ExpenseManaging {
    var coffeePrice: Double
    var coffeeGroupId: Int? = nil
    var coffeeAccountId: Int? = nil
    
    fileprivate let splitwiseConnector: SplitwiseConnector
    fileprivate var user: User?
    fileprivate var groupsOfUser: [Group]?
    
    init() {
        splitwiseConnector = SplitwiseConnector();
        coffeePrice = 0.5
    }
    
    func logIn(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        splitwiseConnector.authorize(success: success, failure: failure)
    }
    
    func setup(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        splitwiseConnector.httpGetCurrentUser(success: { user in
            self.user = user
            
            self.splitwiseConnector.httpGetGroupsWithMembers(success: { groups in
                self.groupsOfUser = groups
                
                success()
            }, failure: failure)
        }, failure: failure)
    }
    
    func currentUser() -> User? {
        return user
    }
    
    func groups() -> [String] {
        return groupsOfUser?.map { $0.name } ?? []
    }
    
    func membersFor(group: String) -> [(/*name:*/ String, /*id:*/ Int)] {
        return groupsOfUser?.reduce([]) { $1.name == group ? $1.members.map { ($0.name, $0.id ) } : $0 } ?? []
    }
    
    func currenciesFor(group: String) -> [String] {
        return groupsOfUser?.reduce([]) { $1.name == group ? $1.currencies : $0 } ?? []
    }
    
    func idFor(group: String) -> Int? {
        return groupsOfUser?.filter { $0.name == group }.first?.id
    }
    
    func addCoffeeExpense(numberOfCoffees: Int, success: @escaping () -> Void) {
//        let payment = Payment(numberOfCoffees: numberOfCoffees)
        splitwiseConnector.httpPostExpense(numberOfCoffees: numberOfCoffees, success: {
            success()
        }, failure: { _ in
            
        })
    }
    
    
}
