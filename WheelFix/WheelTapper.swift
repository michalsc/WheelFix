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

protocol WheelTapperDelegate {
    func processedEventCountChangedTo(value: UInt64)
    func discardedEventCountChangedTo(value: UInt64)
}

// Event filter callback. Here the event will be filtered out or processed
// according to settings in the WheelTapper class
func myCGEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {

    // Extract WheelTapper instance from raw pointer in userData
    let tapper = Unmanaged<WheelTapper>.fromOpaque(refcon!).takeUnretainedValue()

    // If wheel event is continuous, i.e. if it is pixel based
    if 0 == event.getIntegerValueField(.scrollWheelEventIsContinuous) {
        // Get timestamp of the event and the movement delta
        let ts = event.timestamp
        let delta = event.getIntegerValueField(.scrollWheelEventPointDeltaAxis1)
        let fpDelta = event.getIntegerValueField(.scrollWheelEventFixedPtDeltaAxis1)
        
        // Shall spurious sign changes be filtered? If yes they must occur shortly enough
        // after last event (shorter than inactivityDelay) but not be sent too quickly
        // (time distance longer than continuousDelay).
        if tapper.ignoreSpuriousSigns {
            if ((ts - tapper.lastEventTS) < tapper.inactivityDelay) && ((ts - tapper.lastEventTS) > tapper.continuousDelay) {
                // Test if delta movement sign has changed
                if delta * tapper.lastEventDelta < 0 {
                    // Just discard the event completely, do not store timestamp or
                    // delta of the event
                    tapper.discardedEventCount = tapper.discardedEventCount + 1
                    if ts - tapper.lastDelegateCallTS > 100000000 {
                        tapper.lastDelegateCallTS = ts
                        tapper.delegate?.discardedEventCountChangedTo(value: tapper.discardedEventCount)
                    }
                    return nil
                }
            }
        }
        if fpDelta < 0 && fpDelta > -65536 {
            event.setIntegerValueField(.scrollWheelEventFixedPtDeltaAxis1, value: -65536)
        } else if fpDelta > 0 && fpDelta < 65536 {
            event.setIntegerValueField(.scrollWheelEventFixedPtDeltaAxis1, value: 65536)
        }

        tapper.processedEventCount = tapper.processedEventCount + 1
        if ts - tapper.lastDelegateCallTS > 100000000 {
            tapper.lastDelegateCallTS = ts
            tapper.delegate?.processedEventCountChangedTo(value: tapper.processedEventCount)
        }
        
        // Update last event timestamp and movement delta
        tapper.lastEventTS = ts
        tapper.lastEventDelta = delta
        tapper.lastEventFPDelta = fpDelta

        // Place for further event manipulation...
    }

    // Return event for further processing
    return Unmanaged.passRetained(event)
}

class WheelTapper: NSObject, PreferencesWindowDelegate {
    var ignoreSpuriousSigns: Bool
    var lastEventTS: UInt64
    var lastEventDelta: Int64
    var lastEventFPDelta: Int64
    var inactivityDelay: UInt64
    var continuousDelay: UInt64
    var discardedEventCount: UInt64
    var processedEventCount: UInt64
    var lastDelegateCallTS: UInt64

    var delegate: WheelTapperDelegate?

    func preferencesDidUpdate() {
        let defaults = UserDefaults.standard

        ignoreSpuriousSigns = defaults.value(forKey: "ignoreSpuriousSigns") as? Bool ?? true
        inactivityDelay = defaults.value(forKey: "inactivityDelay") as? UInt64 ?? 100000000
        continuousDelay = defaults.value(forKey: "continuousDelay") as? UInt64 ?? 5000000
    }

    enum TapperError : Error {
        case cannotCreateEventTap
    }

    init(ignoreSpuriousSigns: Bool) throws {
        let defaults = UserDefaults.standard

        self.ignoreSpuriousSigns = defaults.value(forKey: "ignoreSpuriousSigns") as? Bool ?? ignoreSpuriousSigns
        self.lastEventTS = 0
        self.lastEventDelta = 0
        self.lastEventFPDelta = 0
        self.inactivityDelay = defaults.value(forKey: "inactivityDelay") as? UInt64 ?? 100000000
        self.continuousDelay = defaults.value(forKey: "continuousDelay") as? UInt64 ?? 5000000
        self.discardedEventCount = 0
        self.processedEventCount = 0
        self.lastDelegateCallTS = 0
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
