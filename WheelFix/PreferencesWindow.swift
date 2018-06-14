//
//  PreferencesWindow.swift
//  WheelFix
//
//  Created by Michal Schulz on 11.06.18.
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

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var inactivityDelayText: NSTextField!
    @IBOutlet weak var continuousDelayText: NSTextField!
    @IBOutlet weak var ignoreSpuriousSigns: NSButton!

    var delegate: PreferencesWindowDelegate?

    override var windowNibName: NSNib.Name! {
        return NSNib.Name(rawValue: "PreferencesWindow")
    }

    override func windowDidLoad() {
        let defaults = UserDefaults.standard
        super.windowDidLoad()

        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        if defaults.value(forKey: "ignoreSpuriousSigns") as? Bool ?? true {
            ignoreSpuriousSigns.state = .on
        } else {
            ignoreSpuriousSigns.state = .off
        }

        var number: Double = Double(defaults.value(forKey: "inactivityDelay") as? UInt64 ?? 100000000) / 1000000.0

        inactivityDelayText.stringValue = (inactivityDelayText.formatter as? NumberFormatter)!.string(from: NSNumber(value: number))!

        number = Double(defaults.value(forKey: "continuousDelay") as? UInt64 ?? 5000000) / 1000000.0

        continuousDelayText.stringValue = (continuousDelayText.formatter as? NumberFormatter)!.string(from: NSNumber(value: number))!

    }

    func windowWillClose(_ notification: Notification) {
        let defaults = UserDefaults.standard
        var number: UInt64

        defaults.setValue(ignoreSpuriousSigns.state == .on, forKey: "ignoreSpuriousSigns")

        number = UInt64(((inactivityDelayText.formatter as? NumberFormatter)!.number(from: inactivityDelayText.stringValue) as! Double) * 1000000)
        defaults.setValue(number, forKey: "inactivityDelay")

        number = UInt64(((continuousDelayText.formatter as? NumberFormatter)!.number(from: continuousDelayText.stringValue) as! Double) * 1000000)
        defaults.setValue(number, forKey: "continuousDelay")

        delegate?.preferencesDidUpdate()
    }
}
