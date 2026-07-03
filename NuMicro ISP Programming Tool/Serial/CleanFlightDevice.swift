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
//  CleanFlightDevice.swift
//  SerialDeviceSwift
//
//  Created by Artem Hruzd on 3/9/18.
//  Copyright © 2018 Artem Hruzd. All rights reserved.
//

import Foundation
import IOKit.serial
import USBDeviceSwift

public enum PortError: Int32, Error {
    case failedToOpen = -1 // refer to open()
    case invalidPath
    case mustReceiveOrTransmit
    case mustBeOpen
    case stringsMustBeUTF8
}

class CleanFlightDevice {
    var deviceInfo:SerialDevice
    var fileDescriptor:Int32?
    
    required init(_ deviceInfo:SerialDevice) {
        self.deviceInfo = deviceInfo
    }
    
    func openPort(toReceive receive: Bool, andTransmit transmit: Bool) throws {
        guard !deviceInfo.path.isEmpty else {
            throw PortError.invalidPath
        }
        
        guard receive || transmit else {
            throw PortError.mustReceiveOrTransmit
        }

        var readWriteParam : Int32
        
        if receive && transmit {
            readWriteParam = O_RDWR
        } else if receive {
            readWriteParam = O_RDONLY
        } else if transmit {
            readWriteParam = O_WRONLY
        } else {
            fatalError()
        }
    
        fileDescriptor = open(deviceInfo.path, readWriteParam | O_NOCTTY | O_NONBLOCK)
        
        // Throw error if open() failed
        if fileDescriptor == PortError.failedToOpen.rawValue {
            throw PortError.failedToOpen
        }
    }
    
    public func closePort() {
        if let fileDescriptor = fileDescriptor {
            close(fileDescriptor)
        }
        fileDescriptor = nil
    }
}
