//
//  ISPManager.swift
//  NuMicro ISP Programming Tool
//
//  Created by MS70MAC on 2024/4/10.
//

import Foundation
import Cocoa

class ISPManager {
    // 單例實例
    static let shared = ISPManager()
    // 連接的設備
    static var connectedDevice: RFDevice? = nil
    // packetNumber
    static var PACKET_NUMBER: UInt = 0x00000005
    private let timeoutInSeconds = 3
    static var RESP_BUFFER:Data? = nil
    
    // 私有初始化方法，確保只能從內部創建實例
    private init() {
        // 在初始化期間註冊通知
        NotificationCenter.default.addObserver(self, selector: #selector(self.usbConnected), name: .HIDDeviceConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.usbDisconnected), name: .HIDDeviceDisconnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hidReadData), name: .HIDDeviceDataReceived, object: nil)
    }
    
    deinit {
        // 在物件銷毀時取消註冊通知
        NotificationCenter.default.removeObserver(self)
    }
    
    private func isChecksum_PackNo(sendBuffer: [UInt8], readBuffer: [UInt8]?) -> Bool {
        guard let readBuffer = readBuffer else {
            AppDelegate.print("readBuffer == nil")
            return false
        }
        
        // checksum
        let checksum = ISPCommandTool.toChecksumBySendBuffer(sendBuffer: sendBuffer)
        let resultChecksum = ISPCommandTool.toChecksumByReadBuffer(readBuffer: readBuffer)
        
        if checksum != resultChecksum {
            AppDelegate.print("checksum \(checksum) != resultChecksum \(resultChecksum)")
            return false
        }
        
        // checkPackNo
        let packNo = ISPManager.PACKET_NUMBER + 1
        let resultPackNo = ISPCommandTool.toPackNo(readBuffer: readBuffer)
        
        if packNo != resultPackNo {
            AppDelegate.print("packNo \(packNo) != resultPackNo \(resultPackNo)")
            return false
        }
        
        ISPManager.PACKET_NUMBER = packNo + 1
        AppDelegate.print("packNo \(packNo) == resultPackNo \(resultPackNo), checksum \(checksum) == resultChecksum \(resultChecksum)")
        return true
    }
    
    
    // MARK: - send cmd Methods
    
    public func sendCMD_CONNECT(callback: @escaping (_ respBf:Data?, _ isChecksum:Bool, _ isTimeout:Bool) -> Void) {
        
        ISPManager.PACKET_NUMBER = 0x00000001
        let cmd = ISPCommands.CMD_CONNECT
        let sendBuffer = ISPCommandTool.toCMD(cmd: cmd, packetNumber: ISPManager.PACKET_NUMBER)
        ISPManager.connectedDevice!.write(sendBuffer)
        
        let startTime = Date()
        while ISPManager.RESP_BUFFER == nil{
            if Date().timeIntervalSince(startTime) > Double(timeoutInSeconds) {
                break
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        if(ISPManager.RESP_BUFFER == nil){
            //timeout
            callback(ISPManager.RESP_BUFFER, false,true)
            return
        }
        
        let isChecksum = self.isChecksum_PackNo(sendBuffer: sendBuffer, readBuffer: ISPManager.RESP_BUFFER!.toUint8Array)
        
        callback(ISPManager.RESP_BUFFER, isChecksum,false)
    }
    
    
    public func sendCMD_GET_DEVICEID(callback: @escaping (_ restBf:[UInt8]?, _ isChecksum:Bool, _ isTimeout:Bool) -> Void) {
        
        if(ISPManager.connectedDevice == nil){
            return
        }
        
        let cmd = ISPCommands.CMD_GET_DEVICEID
        let sendBuffer = ISPCommandTool.toCMD(cmd: cmd, packetNumber: ISPManager.PACKET_NUMBER)
        
        ISPManager.connectedDevice!.write(sendBuffer)
        
        let startTime = Date()
        while ISPManager.RESP_BUFFER == nil{
            if Date().timeIntervalSince(startTime) > Double(timeoutInSeconds) {
                break
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        if(ISPManager.RESP_BUFFER == nil){
            //timeout
            callback(nil, false,true)
            return
        }
        
        let isChecksum = self.isChecksum_PackNo(sendBuffer: sendBuffer, readBuffer: ISPManager.RESP_BUFFER!.toUint8Array)
        
        callback(ISPManager.RESP_BUFFER?.toUint8Array, isChecksum,false)
    }
    
    public func sendCMD_GET_FWVER(callback: @escaping (_ restBf:[UInt8]?, _ isChecksum:Bool, _ isTimeout:Bool) -> Void) {
        
        let cmd = ISPCommands.CMD_GET_FWVER
        let sendBuffer = ISPCommandTool.toCMD(cmd: cmd, packetNumber: ISPManager.PACKET_NUMBER)
        
        ISPManager.connectedDevice!.write(sendBuffer)
        
        let startTime = Date()
        while ISPManager.RESP_BUFFER == nil{
            if Date().timeIntervalSince(startTime) > Double(timeoutInSeconds) {
                break
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        if(ISPManager.RESP_BUFFER == nil){
            //timeout
            callback(nil, false,true)
            return
        }
        
        let isChecksum = self.isChecksum_PackNo(sendBuffer: sendBuffer, readBuffer: ISPManager.RESP_BUFFER!.toUint8Array)
        
        callback(ISPManager.RESP_BUFFER?.toUint8Array, isChecksum,false)
    }
    
    public func sendCMD_ERASE_ALL(callback: @escaping (_ restBf:[UInt8]?, _ isChecksum:Bool, _ isTimeout:Bool) -> Void) {
        
        let cmd = ISPCommands.CMD_ERASE_ALL
        let sendBuffer = ISPCommandTool.toCMD(cmd: cmd, packetNumber: ISPManager.PACKET_NUMBER)
        
        ISPManager.connectedDevice!.write(sendBuffer)
        
        let startTime = Date()
        while ISPManager.RESP_BUFFER == nil{
            if Date().timeIntervalSince(startTime) > Double(timeoutInSeconds) {
                break
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        if(ISPManager.RESP_BUFFER == nil){
            //timeout
            callback(nil, false,true)
            return
        }
        
        let isChecksum = self.isChecksum_PackNo(sendBuffer: sendBuffer, readBuffer: ISPManager.RESP_BUFFER!.toUint8Array)
        
        callback(ISPManager.RESP_BUFFER?.toUint8Array, isChecksum,false)
    }
    
    public func sendCMD_RUN_APROM(callback: @escaping (_ restBf:[UInt8]?, _ isChecksum:Bool, _ isTimeout:Bool) -> Void) {
        
        let cmd = ISPCommands.CMD_RUN_APROM
        let sendBuffer = ISPCommandTool.toCMD(cmd: cmd, packetNumber: ISPManager.PACKET_NUMBER)
        
        ISPManager.connectedDevice!.write(sendBuffer)
        
        let startTime = Date()
        while ISPManager.RESP_BUFFER == nil{
            if Date().timeIntervalSince(startTime) > Double(timeoutInSeconds) {
                break
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        if(ISPManager.RESP_BUFFER == nil){
            //timeout
            callback(nil, false,true)
            return
        }
        
        let isChecksum = self.isChecksum_PackNo(sendBuffer: sendBuffer, readBuffer: ISPManager.RESP_BUFFER!.toUint8Array)
        
        callback(ISPManager.RESP_BUFFER?.toUint8Array, isChecksum,false)
    }
    
    public func sendCMD_UPDATE_BIN(cmd: ISPCommands, sendByteArray: Data, startAddress: UInt, callback: @escaping (_ restBf:[UInt8]?, _ isFailed:Bool,  _ progress:Int) -> Void) {
        
        
        // 如果是其他情況（例如未指定介面類型），則執行一般的命令發送流程
        if cmd != .CMD_UPDATE_APROM && cmd != .CMD_UPDATE_DATAFLASH {
            return
        }
        
        //        // 如果是CAN
        //        if ISPManager.interfaceType == NulinkInterfaceType.CAN {
        //            self.sendCMD_CAN_UPDATE_BIN(sendByteArray, startAddress, callback: callback)
        //            return
        //        }
        
        // 分割資料
        let firstData = sendByteArray.subdata(in: 0..<48) // 第一個 CMD 為 48 byte
        let remainData = sendByteArray.subdata(in: 48..<sendByteArray.count) // 第二以後 CMD 為 56 byte
        var remainDataList: [Data] = []
        
        var index = 0
        var dataArray = Data()
        for byte in remainData {
            dataArray.append(byte)
            index += 1
            
            if index == 56 {
                index = 0
                remainDataList.append(dataArray)
                dataArray.removeAll()
            }
        }
        
        // 如果還有剩餘資料
        if !dataArray.isEmpty {
            // 補齊至 56 byte
            while dataArray.count < 56 {
                dataArray.append(0x00)
            }
            
            remainDataList.append(dataArray)
        }
        
        AppDelegate.print("CMD_UPDATE   CMD: \(cmd)  size: \(sendByteArray.count)  allPackNum: \(remainDataList.count + 1)")
        
        // 寫入第一包資料
        var sendBuffer = ISPCommandTool.toUpdataBin_CMD(cmd: cmd, packetNumber: ISPManager.PACKET_NUMBER, startAddress: startAddress, size: sendByteArray.count, data: firstData, isFirst: true)
        
        ISPManager.connectedDevice!.write(sendBuffer)
        
        let startTime = Date()
        while ISPManager.RESP_BUFFER == nil{
            if Date().timeIntervalSince(startTime) > Double(5) {
                break
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        if(ISPManager.RESP_BUFFER == nil){
            //timeout
            callback(nil,true,-1)
            return
        }
        
        let isChecksum = self.isChecksum_PackNo(sendBuffer: sendBuffer, readBuffer: ISPManager.RESP_BUFFER!.toUint8Array)
        
        if(isChecksum == false){
            callback(nil,true,-1)
            return
        }
        
        callback(ISPManager.RESP_BUFFER?.toUint8Array, false, 0)
        
        // 寫入剩餘的資料
        for (i, data) in remainDataList.enumerated() {
            sendBuffer = ISPCommandTool.toUpdataBin_CMD(cmd: cmd, packetNumber: ISPManager.PACKET_NUMBER, startAddress: 0x000000, size: sendByteArray.count, data: data, isFirst: false)
            
            ISPManager.connectedDevice!.write(sendBuffer)
            
            let startTime = Date()
            while ISPManager.RESP_BUFFER == nil{
                if Date().timeIntervalSince(startTime) > Double(5) {
                    break
                }
                Thread.sleep(forTimeInterval: 0.1)
            }
            
            if(ISPManager.RESP_BUFFER == nil){
                //timeout
                callback(nil,true,-1)
                return
            }
            
            let isChecksum = self.isChecksum_PackNo(sendBuffer: sendBuffer, readBuffer: ISPManager.RESP_BUFFER!.toUint8Array)
            
            if(isChecksum == false){
                callback(nil,true,-1)
                return
            }
            
            let p = Int(Double(i) / Double(remainDataList.count) * 100)
            callback(ISPManager.RESP_BUFFER?.toUint8Array, false, p)
            
        }
        
        // 寫入完成
        callback(ISPManager.RESP_BUFFER?.toUint8Array, false, 100)
    }
    
    func sendCMD_READ_CONFIG(callback: @escaping ((_ restBf:[UInt8]?, _ isChecksum:Bool, _ isTimeout:Bool) -> Void)) {
        
//        let cmd = ISPCommands.CMD_READ_CONFIG
//        let sendBuffer = ISPCommandTool.toCMD(cmd, packetNumber)
//        self.write(sendBuffer)
//        let readBuffer = self.read()
//        let isChecksum = self.isChecksum_PackNo(sendBuffer, readBuffer)
//
//        callback(readBuffer)
        
        let cmd = ISPCommands.CMD_READ_CONFIG
        let sendBuffer = ISPCommandTool.toCMD(cmd: cmd, packetNumber: ISPManager.PACKET_NUMBER)
        
        ISPManager.connectedDevice!.write(sendBuffer)
        
        let startTime = Date()
        while ISPManager.RESP_BUFFER == nil{
            if Date().timeIntervalSince(startTime) > Double(timeoutInSeconds) {
                break
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        if(ISPManager.RESP_BUFFER == nil){
            //timeout
            callback(nil, false,true)
            return
        }
        
        let isChecksum = self.isChecksum_PackNo(sendBuffer: sendBuffer, readBuffer: ISPManager.RESP_BUFFER!.toUint8Array)
        
        callback(ISPManager.RESP_BUFFER?.toUint8Array, isChecksum,false)
        
    }
    
    func sendCMD_UPDATE_CONFIG(config_0: UInt, config_1: UInt, config_2: UInt, config_3: UInt,callback: @escaping ((_ restBf:[UInt8]?, _ isChecksum:Bool, _ isTimeout:Bool) -> Void)) {

        let cmd = ISPCommands.CMD_UPDATE_CONFIG
        let sendBuffer = ISPCommandTool.toUpdataCongigeCMD(config_0: config_0, config_1: config_1, config_2: config_2, config_3: config_3, packetNumber: ISPManager.PACKET_NUMBER)
        ISPManager.connectedDevice!.write(sendBuffer)

        let startTime = Date()
        while ISPManager.RESP_BUFFER == nil{
            if Date().timeIntervalSince(startTime) > Double(timeoutInSeconds) {
                break
            }
            Thread.sleep(forTimeInterval: 0.1)
        }

        if(ISPManager.RESP_BUFFER == nil){
            //timeout
            callback(nil, false,true)
            return
        }

        let isChecksum = self.isChecksum_PackNo(sendBuffer: sendBuffer, readBuffer: ISPManager.RESP_BUFFER!.toUint8Array)

        callback(ISPManager.RESP_BUFFER?.toUint8Array, isChecksum,false)
    }
    
    // MARK: - Notification Methods
    
    @objc func usbConnected(_ notification: Notification) {
        // 處理 USB 連接通知
        AppDelegate.print("USB connected")
    }
    
    @objc func usbDisconnected(_ notification: Notification) {
        // 處理 USB 斷開連接通知
        AppDelegate.print("USB disconnected")
    }
    
    @objc func hidReadData(_ notification: Notification) {
        // 處理 HID 讀取數據通知
        let obj = notification.object as! NSDictionary
        let data = obj["data"] as! Data
        ISPManager.RESP_BUFFER = data
        //data to hex string
        AppDelegate.print("readData:\n\(data.toHexString())")
        
    }
}
