//
//  Copyright © 2018 Jan Wasgint. All rights reserved.
//

import Cocoa

let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
let popover = NSPopover()
var monitor: Any?
var closesOnPressOutsidePopover = false

var expenseManager: ExpenseManaging = ExpenseManager()
