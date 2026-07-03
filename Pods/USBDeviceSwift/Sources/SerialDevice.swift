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
//  SerialDevice.swift
//  USBDeviceSwift
//
//  Created by Artem Hruzd on 3/9/18.
//  Copyright © 2018 Artem Hruzd. All rights reserved.
//

import Foundation
import IOKit.serial


public extension Notification.Name {
    static let SerialDeviceAdded = Notification.Name("SerialDeviceAdded")
    static let SerialDeviceRemoved = Notification.Name("SerialDeviceRemoved")
}

public struct SerialDevice {
    public let path:String
    public var name:String? // USB Product Name
    public var vendorName:String? //USB Vendor Name
    public var serialNumber:String? //USB Serial Number
    public var vendorId:Int? //USB Vendor id
    public var productId:Int? //USB Product id
    
    init(path:String) {
        self.path = path
    }
}

extension SerialDevice: Hashable {
    public var hashValue: Int {
        return "\(path)".hashValue
    }
    
    public static func ==(lhs: SerialDevice, rhs: SerialDevice) -> Bool {
        return lhs.path == rhs.path
    }
}
