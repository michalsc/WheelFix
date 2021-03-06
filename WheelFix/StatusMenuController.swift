//
//  StatusMenuController.swift
//  WheelFix
//
//  Created by Michal Schulz on 08.06.18.
//  Copyright © 2018 Michal Schulz. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//      You should have received a copy of the GNU General Public License
//      along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Cocoa

class StatusMenuController: NSObject, WheelTapperDelegate, PreferencesWindowDelegate {
    @IBOutlet weak var statusMenu: NSMenu!

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var preferencesWindow: PreferencesWindow!
    var tapper: WheelTapper!

    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }

    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
    }

    func preferencesDidUpdate() {
        debugPrint("Controller.preferencesDidUpdate")
        tapper?.preferencesDidUpdate()
    }

    func processedEventCountChangedTo(value: UInt64) {
        statusMenu.item(withTag: 1)?.title = "Events processed: " + String(value)
    }

    func discardedEventCountChangedTo(value: UInt64) {
        statusMenu.item(withTag: 2)?.title = "Events discarded: " + String(value)
    }

    override func awakeFromNib() {
        let icon = NSImage(named: NSImage.Name(rawValue: "statusIcon"))
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        do {
            try tapper = WheelTapper(ignoreSpuriousSigns: true)
        } catch {

        }
        preferencesWindow = PreferencesWindow()

        preferencesWindow?.delegate = self
        tapper?.delegate = self
    }
}
