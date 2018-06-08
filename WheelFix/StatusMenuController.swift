//
//  StatusMenuController.swift
//  WheelFix
//
//  Created by Michal Schulz on 08.06.18.
//  Copyright © 2018 Michal Schulz. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }

    override func awakeFromNib() {
        let icon = NSImage(named: NSImage.Name(rawValue: "statusIcon"))
        statusItem.image = icon
        statusItem.menu = statusMenu
    }
}
