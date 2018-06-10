//
//  AppDelegate.swift
//  WheelFix
//
//  Created by Michal Schulz on 08.06.18.
//  Copyright © 2018 Michal Schulz. All rights reserved.
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

