//
//  Copyright © 2018 Jan Wasgint. All rights reserved.
//

struct Group {
    let id: Int
    let name: String
    let currencies: [String]
    let members: [User]
    
    init(id: Int, name: String, members: [User], currencies: [String]) {
        self.id = id
        self.name = name
        self.members = members
        self.currencies = currencies
    } 
}
