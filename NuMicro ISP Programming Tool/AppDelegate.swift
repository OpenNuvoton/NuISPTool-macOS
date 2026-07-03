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
//  AppDelegate.swift
//  NuMicro ISP Programming Tool
//
//  Created by MS70MAC on 2024/3/5.
//

import Cocoa
import USBDeviceSwift

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    //宣告 HID Device白名單
    let rfDeviceMonitor = HIDDeviceMonitor([
        HIDMonitorData(vendorId: 1046, productId: 16128), //HID
        HIDMonitorData(vendorId: 5218, productId: 16292),  //NU-LINK
        HIDMonitorData(vendorId: 1046, productId: 16144), //ISP-Bridge
//        HIDMonitorData(vendorId: 1046, productId: 8196) //ISP-Bridge
        ], reportSize: 64)
    
    let cfDeviceMonitor = SerialDeviceMonitor()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        //開始搜尋 HID Device
        let rfDeviceDaemon = Thread(target: self.rfDeviceMonitor, selector:#selector(self.rfDeviceMonitor.start), object: nil)
        rfDeviceDaemon.start()
        
        // Adding own function to filter serial devices that we need
        cfDeviceMonitor.filterDevices = {(devices: [SerialDevice]) -> [SerialDevice] in
            let whitelist: [(vendorId: Int, productId: Int)] = [
                (1046, 8196), // 添加白名單的 vendorId 和 productId 组合
                (1046, 20992), // 另一组白名單
                (1046, 20994), // 另一组白名單
                (1046, 20765),
            ]
            return devices.filter { device in
                whitelist.contains { $0.vendorId == device.vendorId && $0.productId == device.productId }
            }
        }
        
        let cfDeviceDaemon = Thread(target: self.cfDeviceMonitor, selector:#selector(self.cfDeviceMonitor.start), object: nil)
        cfDeviceDaemon.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    public static func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let isPrint = true
        if(isPrint == true){
            let prefix = "[MyApp]"
            Swift.print(prefix, terminator: separator)
            for item in items {
                Swift.print(item, terminator: separator)
            }
            Swift.print("", terminator: terminator)
        }
    }

}

