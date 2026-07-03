/*
 * Copyright 2026 Nuvoton Technology Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  HIDDeviceMonitor.swift
//  USBDeviceSwift
//
//  Created by Artem Hruzd on 6/14/17.
//  Copyright © 2017 Artem Hruzd. All rights reserved.
//

import Cocoa
import Foundation
import IOKit.hid


open class HIDDeviceMonitor {
    public let vp:[HIDMonitorData]
    public let reportSize:Int
    
    public init(_ vp:[HIDMonitorData], reportSize:Int) {
        self.vp = vp
        self.reportSize = reportSize
    }
    
    @objc open func start() {
        let managerRef = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        var deviceMatches:[[String:Any]] = []
        for vp in self.vp {
            deviceMatches.append([kIOHIDProductIDKey: vp.productId, kIOHIDVendorIDKey: vp.vendorId])
        }
        IOHIDManagerSetDeviceMatchingMultiple(managerRef, deviceMatches as CFArray)
        IOHIDManagerScheduleWithRunLoop(managerRef, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue);
        IOHIDManagerOpen(managerRef, IOOptionBits(kIOHIDOptionsTypeNone));
        
        let matchingCallback:IOHIDDeviceCallback = { inContext, inResult, inSender, inIOHIDDeviceRef in
            let this:HIDDeviceMonitor = unsafeBitCast(inContext, to: HIDDeviceMonitor.self)
            this.rawDeviceAdded(inResult, inSender: inSender!, inIOHIDDeviceRef: inIOHIDDeviceRef)
        }
        
        let removalCallback:IOHIDDeviceCallback = { inContext, inResult, inSender, inIOHIDDeviceRef in
            let this:HIDDeviceMonitor = unsafeBitCast(inContext, to: HIDDeviceMonitor.self)
            this.rawDeviceRemoved(inResult, inSender: inSender!, inIOHIDDeviceRef: inIOHIDDeviceRef)
        }
        IOHIDManagerRegisterDeviceMatchingCallback(managerRef, matchingCallback, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
        IOHIDManagerRegisterDeviceRemovalCallback(managerRef, removalCallback, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
        
        
        RunLoop.current.run()
    }
    
    open func read(_ inResult: IOReturn, inSender: UnsafeMutableRawPointer, type: IOHIDReportType, reportId: UInt32, report: UnsafeMutablePointer<UInt8>, reportLength: CFIndex) {
        let data = Data(bytes: UnsafePointer<UInt8>(report), count: reportLength)
        NotificationCenter.default.post(name: .HIDDeviceDataReceived, object: ["data": data])
    }
    
    open func rawDeviceAdded(_ inResult: IOReturn, inSender: UnsafeMutableRawPointer, inIOHIDDeviceRef: IOHIDDevice!) {
        // It would be better to look up the report size and create a chunk of memory of that size
        let report = UnsafeMutablePointer<UInt8>.allocate(capacity: reportSize)
        let inputCallback : IOHIDReportCallback = { inContext, inResult, inSender, type, reportId, report, reportLength in
            let this:HIDDeviceMonitor = unsafeBitCast(inContext, to: HIDDeviceMonitor.self)
            this.read(inResult, inSender: inSender!, type: type, reportId: reportId, report: report, reportLength: reportLength)
        }
        
        //Hook up inputcallback
        IOHIDDeviceRegisterInputReportCallback(inIOHIDDeviceRef!, report, reportSize, inputCallback, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
        
        let device = HIDDevice(device:inIOHIDDeviceRef)
        NotificationCenter.default.post(name: .HIDDeviceConnected, object: ["device": device])
    }
    
    open func rawDeviceRemoved(_ inResult: IOReturn, inSender: UnsafeMutableRawPointer, inIOHIDDeviceRef: IOHIDDevice!) {
        let device = HIDDevice(device:inIOHIDDeviceRef)
        NotificationCenter.default.post(name: .HIDDeviceDisconnected, object: [
            "productId": device.productId
        ])
    }
}
