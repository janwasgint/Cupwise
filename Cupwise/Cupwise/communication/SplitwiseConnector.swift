//
//  Copyright © 2018 Jan Wasgint. All rights reserved.
//

import OAuthSwift
import SwiftyJSON

fileprivate let consumerKey = "" // go to https://secure.splitwise.com/oauth_clients to obtain a consumerKey or use provided binary
fileprivate let consumerSecret = "" // go to https://secure.splitwise.com/oauth_clients to obtain a consumerSecret or use provided binary

class SplitwiseConnector {
    fileprivate let oauthswift = OAuth1Swift(
        consumerKey: consumerKey,
        consumerSecret: consumerSecret,
        requestTokenUrl: "https://secure.splitwise.com/oauth/request_token",
        authorizeUrl:    "https://secure.splitwise.com/oauth/authorize",
        accessTokenUrl:  "https://secure.splitwise.com/oauth/access_token")
    fileprivate var requestHandle: OAuthSwiftRequestHandle?
    fileprivate var client: OAuthSwiftClient?
    
    func previousAuthorizationAvailable() -> Bool {
        if let oauthToken = UserDefaults.standard.string(forKey: "oauthToken"),
            let oauthTokenSecret = UserDefaults.standard.string(forKey: "oauthTokenSecret"),
            let oauthTokenExpiresAtString = UserDefaults.standard.string(forKey: "oauthTokenExpiresAt") {
            
            if let oauthTokenExpiresAt = Date.toDate(string: oauthTokenExpiresAtString),
                Date() > oauthTokenExpiresAt {
                return false
            } else {
                client = OAuthSwiftClient(consumerKey: consumerKey, consumerSecret: consumerSecret, oauthToken: oauthToken, oauthTokenSecret: oauthTokenSecret, version: .oauth1)
                return true
            }
        }
        return false
    }
    
    func authorize(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        requestHandle = oauthswift.authorize(withCallbackURL: URL(string: "Cupwise://oob")!,
                                             success: { credential, response, parameters in
                                                UserDefaults.standard.set(credential.oauthToken, forKey: "oauthToken")
                                                UserDefaults.standard.set(credential.oauthTokenSecret, forKey: "oauthTokenSecret")
                                                UserDefaults.standard.set(credential.oauthTokenExpiresAt?.toDateTimeStamp() ?? "-", forKey: "oauthTokenExpiresAt")
                                                self.client = self.oauthswift.client
                                                success()
        }, failure: { error in
            failure(error.localizedDescription)
        })
    }
    
    func httpGetGroupsWithMembers(success: @escaping ([Group]) -> Void, failure: @escaping (String) -> Void) {
        guard let client = self.client else {
            failure("Not authorized. Call authorize(...) before using")
            return
        }
        _ = client.get("https://secure.splitwise.com/api/v3.0/get_groups", success: { response in
            let responseJSON = JSON(parseJSON: response.dataString() ?? "")
            let groupsJSON = responseJSON["groups"].arrayValue
            var groups = [Group]()
            
            for groupJSON in groupsJSON {
                let groupId = groupJSON["id"].intValue
                let groupName = groupJSON["name"].stringValue
                let groupMembersJSON = groupJSON["members"].arrayValue
                
                var currencies = [String]()
                let originalDeptsJSON = groupJSON["original_debts"].arrayValue
                for originalDeptJSON in originalDeptsJSON {
                    let currency = originalDeptJSON["currency_code"].stringValue
                    if (!currencies.contains { $0 == currency}) {
                        currencies.append(currency)
                    }
                }
                
                var members = [User]()
                for groupMemberJSON in groupMembersJSON {
                    let memberId = groupMemberJSON["id"].intValue
                    let memberFirstName = groupMemberJSON["first_name"].stringValue
                    let memberLastName = groupMemberJSON["last_name"].stringValue
                    let memberEmail = groupMemberJSON["email"].stringValue
                    let memberDefaultCurrency = groupMemberJSON["default_currency"].stringValue
                    
                    let member = User(id: memberId, firstName: memberFirstName, lastName: memberLastName, email: memberEmail, defaultCurrency: memberDefaultCurrency)
                    members.append(member)
                }
                
                let group = Group(id: groupId, name: groupName, currencies: currencies, members: members)
                groups.append(group)
            }
            success(groups)
        }, failure: { error in
            failure(error.localizedDescription)
        })
    }
    
    func httpGetCurrentUser(success: @escaping (User) -> Void, failure: @escaping (String) -> Void) {
        guard let client = self.client else {
            failure("Not authorized. Call authorize(...) before using")
            return
        }
        _ = client.get("https://secure.splitwise.com/api/v3.0/get_current_user", success: { response in
            let responseJSON = JSON(parseJSON: response.dataString() ?? "")
            let userJSON = responseJSON["user"]
            
            let id = userJSON["id"].intValue
            let firstName = userJSON["first_name"].stringValue
            let lastName = userJSON["last_name"].stringValue
            let email = userJSON["email"].stringValue
            let defaultCurrency = userJSON["default_currency"].stringValue
            
            let user = User(id: id, firstName: firstName, lastName: lastName, email: email, defaultCurrency: defaultCurrency)
            success(user)
        }, failure: { error in
            failure(error.localizedDescription)
        })
    }
    
    func httpPostExpense(numberOfCoffees: Int, success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        guard let client = self.client else {
            failure("Not authorized. Call authorize(...) before using")
            return
        }
        guard let groupId = expenseManager.coffeeGroupId,
            let userId = expenseManager.currentUser()?.id,
            let defaultCurrency = expenseManager.currentUser()?.defaultCurrency,
            let accountId = expenseManager.coffeeAccountId else {
            failure("No group or account to pay specified")
            return
        }
        let totalCost = expenseManager.coffeePrice * Double(numberOfCoffees)
        let description = numberOfCoffees == 1 ? "Coffee" : "\(numberOfCoffees) x Coffee"
        
        let parameters: OAuthSwift.Parameters = [
            "payment" : false,
            "cost" : totalCost,
            "description" : description,
            "details" : "Added via Cupwise (Free download at https://github.com/janwasgint/Cupwise)",
            "group_id" : groupId,
            "currency_code" : defaultCurrency,
            "users__1__user_id" : userId,
            "users__1__paid_share" : 0.0,
            "users__1__owed_share" : totalCost,
            "users__2__user_id" : accountId,
            "users__2__paid_share" : totalCost,
            "users__2__owed_share" : 0.0
        ]
        _ = client.post("https://secure.splitwise.com/api/v3.0/create_expense", parameters: parameters, success: {  response in
            success()
        }, failure: { error in
            failure(error.localizedDescription)
        })
    }
}
