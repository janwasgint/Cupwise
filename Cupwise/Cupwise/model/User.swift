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
}
