//
//  Copyright © 2018 Jan Wasgint. All rights reserved.
//

struct User {
    let id: Int
    let firstName: String
    let lastName: String
    var name: String { return "\(firstName) \(lastName)"}
    let email: String
    let defaultCurrency: String
    
    init(id: Int, firstName: String, lastName: String, email: String, defaultCurrency: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.defaultCurrency = defaultCurrency
    }
}
