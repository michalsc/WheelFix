//
//  AppDelegate.swift
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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var tapper: WheelTapper?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        do {
            try tapper = WheelTapper(ignoreSpuriousSigns: true)
        } catch {
            print("Error creating tapper")
            exit(1)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

