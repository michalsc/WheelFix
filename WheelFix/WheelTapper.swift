//
//  WheelTapper.swift
//  WheelFix
//
//  Created by Michal Schulz on 09.06.18.
//  Copyright © 2018 Michal Schulz. All rights reserved.
//

import Cocoa

func myCGEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {

    debugPrint("we are monitoring the mouse event here")
    return nil
}

class WheelTapper: NSObject {
    var ignoreSpuriousSigns: Bool

    override init() {
        print("Initializing class");

        self.ignoreSpuriousSigns = false

        let eventMask = (1 << CGEventType.scrollWheel.rawValue)

        if let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                            place: .headInsertEventTap,
                                            options: .defaultTap,
                                            eventsOfInterest: CGEventMask(eventMask),
                                            callback: myCGEventCallback,
                                            userInfo: nil) {
            print("starting to tak wheel events")
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
        }
        else {
            print("failed to create event tap")
            exit(1)
        }
    }
}
