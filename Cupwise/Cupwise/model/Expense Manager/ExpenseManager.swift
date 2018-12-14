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
    
    func loggedIn() -> Bool {
        return splitwiseConnector.previousAuthorizationAvailable()
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
    
    func groups() -> [Group] {
        return groupsOfUser ?? []
    }
    
    func addCoffeeExpense(numberOfCoffees: Int, success: @escaping () -> Void) {
        splitwiseConnector.httpPostExpense(numberOfCoffees: numberOfCoffees, success: {
            success()
        }, failure: { _ in
            
        })
    }
}
