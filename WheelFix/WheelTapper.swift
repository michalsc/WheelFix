//
//  WheelTapper.swift
//  WheelFix
//
//  Created by Michal Schulz on 09.06.18.
//  Copyright © 2018 Michal Schulz. All rights reserved.
//

import Cocoa

func myCGEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {

    let tapper = Unmanaged<WheelTapper>.fromOpaque(refcon!).takeUnretainedValue()

    if 0 != event.getIntegerValueField(.scrollWheelEventIsContinuous) {
        let ts = event.timestamp
        let delta = event.getIntegerValueField(.scrollWheelEventPointDeltaAxis1)
        if tapper.ignoreSpuriousSigns {
            if ((ts - tapper.lastEventTS) < tapper.inactivityDelay) && ((ts - tapper.lastEventTS) > tapper.continuousDelay) {
                if delta * tapper.lastEventDelta < 0 {
                    debugPrint("unusual sign change in wheel, timestamp difference is %f ms. Skipping event", Double(ts - tapper.lastEventTS) / 1000000.0)
                    debugPrint(delta)
                    return nil
                }
            }
        }
        tapper.lastEventTS = ts
        tapper.lastEventDelta = delta
    }

    return Unmanaged.passRetained(event)
}

class WheelTapper: NSObject {
    var ignoreSpuriousSigns: Bool
    var lastEventTS: UInt64
    var lastEventDelta: Int64
    var inactivityDelay: UInt64
    var continuousDelay: UInt64

    enum TapperError : Error {
        case cannotCreateEventTap
    }

    init(ignoreSpuriousSigns: Bool) throws {
        self.ignoreSpuriousSigns = ignoreSpuriousSigns
        self.lastEventTS = 0
        self.lastEventDelta = 0
        self.inactivityDelay = 100000000
        self.continuousDelay = 5000000
        super.init()

        // Observe scrollWheel events
        let eventMask = (1 << CGEventType.scrollWheel.rawValue)

        // And pass tapper as userInfo to the event tap
        let userInfo = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        // Create and activate tap
        if let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                            place: .headInsertEventTap,
                                            options: .defaultTap,
                                            eventsOfInterest: CGEventMask(eventMask),
                                            callback: myCGEventCallback,
                                            userInfo: userInfo) {
            print("starting to tak wheel events")
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
        }
        else {
            print("failed to create event tap")

            throw TapperError.cannotCreateEventTap
        }
    }
}
