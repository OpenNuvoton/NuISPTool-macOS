//
//  RFDevice.swift
//  RaceflightControllerHIDExample
//
//  Created by Artem Hruzd on 6/17/17.
//  Copyright © 2017 Artem Hruzd. All rights reserved.
//

import Cocoa
import USBDeviceSwift

class RFDevice: NSObject {
    let deviceInfo:HIDDevice
    
    required init(_ deviceInfo:HIDDevice) {
        self.deviceInfo = deviceInfo
    }
    
    func sendCommad(command:String) {
        let safeStr = command.trimmingCharacters(in: .whitespacesAndNewlines)
        if let commandData = safeStr.data(using: .utf8) {
            self.write(commandData)
        }
    }
    
    func sendData(data:Data) {
        self.write(data)
    }
    
    func write(_ data: Data) {
        
        ISPManager.RESP_BUFFER = nil //清除ＢＵＦＦＥＲ
        
        //data to UInt8 array
        var bytesArray = [UInt8](data)
        // 修改第二個字節
        bytesArray[1] = ISPManager.INTERFACE_TYPE.rawValue
        
        if (bytesArray.count > self.deviceInfo.reportSize) {
            AppDelegate.print("Output data too large for USB report")
            return
        }
        
        let correctData = Data(bytes: UnsafePointer<UInt8>(bytesArray), count: self.deviceInfo.reportSize)
        
        IOHIDDeviceSetReport(
            self.deviceInfo.device,
            kIOHIDReportTypeOutput,
            CFIndex(0),// Report ID為0，如果設備不使用Report ID
            (correctData as NSData).bytes.bindMemory(to: UInt8.self, capacity: correctData.count),
            correctData.count
        )
        let hexString = correctData.map { String(format: "%02x", $0) }.joined()
        
        AppDelegate.print("writeData:\(hexString)")
    }
    
    func write(_ data: [UInt8]) {
        
        ISPManager.RESP_BUFFER = nil //清除ＢＵＦＦＥＲ
        var bytesArray = data
        
        // 修改第二個字節
        bytesArray[1] = ISPManager.INTERFACE_TYPE.rawValue
        
        if bytesArray.count > self.deviceInfo.reportSize {
            AppDelegate.print("Output data too large for USB report")
            return
        }
        
        let correctData = Data(bytes: UnsafePointer<UInt8>(bytesArray), count: self.deviceInfo.reportSize)
        
        IOHIDDeviceSetReport(
            self.deviceInfo.device,
            kIOHIDReportTypeOutput,
            CFIndex(0), // Report ID為0，如果設備不使用Report ID
            (correctData as NSData).bytes.bindMemory(to: UInt8.self, capacity: correctData.count),
            correctData.count
        )
        
        let hexString = correctData.map { String(format: "%02x", $0) }.joined()
        AppDelegate.print("writeData:\n\(hexString)")
    }
    
    // Additional: convertion bytes to specific string, removing garbage etc.
    func convertByteDataToString(_ data:Data, removeId:Bool=true, cleanGarbage:Bool=true) -> String {
        let count = data.count / MemoryLayout<UInt8>.size
        var array = [UInt8](repeating: 0, count: count)
        data.copyBytes(to: &array, count:count * MemoryLayout<UInt8>.size)
        if (array.count>0 && removeId) {
            array.remove(at: 0)
        }
        var strResp:String = ""
        for byte in array {
            strResp += String(UnicodeScalar(byte))
        }
        if (cleanGarbage) {
            if let dotRange = strResp.range(of: "\0") {
                strResp.removeSubrange(dotRange.lowerBound..<strResp.endIndex)
            }
        }
        strResp = strResp.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return strResp
    }
}
