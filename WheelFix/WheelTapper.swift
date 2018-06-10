//
//  WheelTapper.swift
//  WheelFix
//
//  Created by Michal Schulz on 09.06.18.
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

// Event filter callback. Here the event will be filtered out or processed
// according to settings in the WheelTapper class
func myCGEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {

    // Extract WheelTapper instance from raw pointer in userData
    let tapper = Unmanaged<WheelTapper>.fromOpaque(refcon!).takeUnretainedValue()

    // If wheel event is continuous, i.e. if it is pixel based
    if 0 != event.getIntegerValueField(.scrollWheelEventIsContinuous) {
        // Get timestamp of the event and the movement delta
        let ts = event.timestamp
        let delta = event.getIntegerValueField(.scrollWheelEventPointDeltaAxis1)

        // Shall spurious sign changes be filtered? If yes they must occur shortly enough
        // after last event (shorter than inactivityDelay) but not be sent too quickly
        // (time distance longer than continuousDelay).
        if tapper.ignoreSpuriousSigns {
            if ((ts - tapper.lastEventTS) < tapper.inactivityDelay) && ((ts - tapper.lastEventTS) > tapper.continuousDelay) {
                // Test if delta movement sign has changed
                if delta * tapper.lastEventDelta < 0 {
                    // Just discard the event completely, do not store timestamp or
                    // delta of the event
                    return nil
                }
            }
        }
        // Update last event timestamp and movement delta
        tapper.lastEventTS = ts
        tapper.lastEventDelta = delta

        // Place for further event manipulation...
    }

    // Return event for further processing
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
