//
//  SerialPortManager.swift
//  NuMicro ISP Programming Tool
//
//  Created by MS70MAC on 2024/6/17.
//


import Foundation
import IOKit
import SwiftSerial

class SerialPortManager {
    static let shared = SerialPortManager()
    
    private var fileHandle: FileHandle?
    private var serialQueue = DispatchQueue(label: "com.serialPortManager.queue")
    private var timeout: TimeInterval = 6.0 // 設置超时时间
    private static var readbuffer = Data()
    
    private init() {
          self.serialQueue = DispatchQueue(label: "com.serialPortManager.queue")
          NotificationCenter.default.addObserver(self, selector: #selector(handleUARTNotification(_:)), name: .serialPortDidReadData, object: nil)
      }
    
    func isPortOpen() -> Bool {
            return fileHandle != nil
        }
    
    func open(portPath: String) -> Bool {
        
        // 建立 SerialPort 實例並開啟串口
        let serialPort = SerialPort(path: portPath)
        do {
            try serialPort.openPort()
            try serialPort.setSettings(
                baudRateSetting: .symmetrical(.baud115200),
                minimumBytesToRead: 1)
                serialPort.closePort()
            // 在這裡繼續進行你的串口通訊操作
        } catch {
            // 捕獲並處理可能的錯誤
            print("Error setting up serial port: \(error)")
            return false
        }
        
        guard let fileHandle = FileHandle(forUpdatingAtPath: portPath) else {
            AppDelegate.print("無法打開裝置")
            return false
        }
        
        
        self.fileHandle = fileHandle

        return true
    }

    func close() {
        fileHandle?.closeFile()
        fileHandle = nil
    }
    
    func clearFileHandle(fileHandle: FileHandle) throws {
        // 将文件句柄移动到文件开始位置
        try fileHandle.seek(toOffset: 0)
        // 将文件截断到0字节，从而清空文件内容
        try fileHandle.truncate(atOffset: 0)
    }
    
    func writeAndRead(data: Data,callback: @escaping (_ respBf:Data?) -> Void) {
        
        guard let fileHandle = fileHandle else {
            AppDelegate.print("裝置尚未打開")
            callback(nil)
            return
        }
        
        var sumData = Data()
  
        AppDelegate.print("UART Write:\(data.toHexString())")
        fileHandle.write(data)
        
        Thread.sleep(forTimeInterval: 0.02)
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global().async {
         
            Thread.sleep(forTimeInterval: 0.01)
            while sumData.count < 64 {
    
                let readData = fileHandle.availableData
                sumData.append(readData)
                
                if sumData.count >= 64 {
                    semaphore.signal()
                    break
                }
            }
        }
        
        let result = semaphore.wait(timeout: .now() + 6)
        
        if result == .success {
            AppDelegate.print("UART read:\(sumData.toHexString())")
            callback(sumData)
            return
        } else {
            callback(nil)
            return
        }
        
    }
    
//    func writeForConnect(data: Data) -> Data? {
//        guard let fileHandle = fileHandle else {
//            AppDelegate.print("裝置尚未打開")
//            return nil
//        }
//
//        guard fileHandle.fileDescriptor != -1 else {
//            // 處理無效的文件句柄
//            print("Invalid file handle")
//            return nil
//        }
//
//        var sumData = Data()
//        var isRead = false
//        var resultData: Data? = nil
//
//        AppDelegate.print("UART Write:\(data.toHexString())")
//
//        // 設置 QoS
//        let queue = DispatchQueue.global(qos: .userInitiated)
//        let semaphore = DispatchSemaphore(value: 0)
//
//        // 引入写操作的控制信号
//        let writeControlSemaphore = DispatchSemaphore(value: 1)
//        
//        queue.async {
//            while !isRead {
//                writeControlSemaphore.wait()
//                guard !isRead else { break } // 检查 isRead 状态
//
//                // 每300ms寫一次
//                AppDelegate.print("UART Write:\(data.toHexString())")
//                fileHandle.write(data)
//                writeControlSemaphore.signal() // 释放信号
//                Thread.sleep(forTimeInterval: 0.3)
//            }
//            writeControlSemaphore.signal() // 确保退出时信号被释放
//        }
//
//        queue.async {
//            while !isRead {
//                Thread.sleep(forTimeInterval: 0.01)
//                let readData = fileHandle.availableData
//                sumData.append(readData)
//                if sumData.count >= 64 {
//                    // 確保sumData的第一個字元不為0x00
//                    if sumData.first != 0x00 {
//                        resultData = sumData.prefix(64) // 只取前64字節
//                        isRead = true
//                        semaphore.signal()
//                        writeControlSemaphore.wait() // 确保写操作被阻止
//                    } else {
//                        // 移除無效的開頭字元，繼續讀取數據
//                        sumData.removeFirst()
//                    }
//                }
//            }
//            do {
//                // 再次读取以清理残余数据
//                let readData = try fileHandle.readToEnd()
//               } catch {}
//        }
//
//        // Timeout handling
//        let timeoutResult = semaphore.wait(timeout: .now() + 6)
//        if timeoutResult == .timedOut {
//            isRead = true
//            writeControlSemaphore.wait() // 确保写操作被阻止
//            AppDelegate.print("Timeout: 未在6秒內收到回應")
//            return nil
//        }
//        
//        // 等待300ms再返回结果
//        Thread.sleep(forTimeInterval: 0.3)
//        
//        AppDelegate.print("sumData:\(resultData!.toHexString())")
//        return resultData
//    }



    func writeForConnect(data: Data) -> Data? {
        guard let fileHandle = fileHandle else {
            AppDelegate.print("裝置尚未打開")
            return nil
        }

        guard fileHandle.fileDescriptor != -1 else {
            // 處理無效的文件句柄
            print("Invalid file handle")
            return nil
        }

        var sumData = Data()
        print("sumDataFirst:\(sumData.toHexString())")
        var isRead = false
        var isReading = false
        var resultData: Data? = nil

        AppDelegate.print("UART Write:\(data.toHexString())")

        // 設置 QoS
        let queue = DispatchQueue.global(qos: .userInitiated)
        let semaphore = DispatchSemaphore(value: 0)
        
        queue.async {
            while !isReading {
                // 每300ms寫一次
                AppDelegate.print("UART Write:\(data.toHexString())")
                fileHandle.write(data)
                Thread.sleep(forTimeInterval: 0.3)
            }
        }

        queue.async {
            while !isRead {
                Thread.sleep(forTimeInterval: 0.01)
                let readData = fileHandle.availableData
                if(!readData.isEmpty && readData.first != 0x00){
                    isReading = true
                }
                sumData.append(readData)
                if sumData.count >= 64 {
                    // 確保sumData的第一個字元不為0x00
                    if sumData.first == 0x00 || sumData.first == 0xFF {
                        // 移除無效的開頭字元，繼續讀取數據
                        print("removeFirst:\(sumData.toHexString())")
                        sumData.removeFirst()
                        if sumData.count >= 64{
                            resultData = sumData.prefix(64) // 只取前64字节
                            isRead = true
                            semaphore.signal()
                        }
                    } else {
                        resultData = sumData.prefix(64) // 只取前64字节
                        isRead = true
                        semaphore.signal()
                    }
                }
            }
        }

        // Timeout handling
            let timeoutResult = semaphore.wait(timeout: .now() + 6)
            if timeoutResult == .timedOut {
                isRead = true
                isReading = true
                AppDelegate.print("Timeout: 未在6秒內收到回應")
                return nil
            }
        
        AppDelegate.print("sumData:\(resultData!.toHexString())")
        Thread.sleep(forTimeInterval: 0.01)
            return resultData
    }
    
    // 處理UART read 通知
    @objc func handleUARTNotification(_ notification: Notification) {
    
        if let data = notification.userInfo?["data"] as? Data {
            if (data.count < 64){
                SerialPortManager.readbuffer = SerialPortManager.readbuffer + data
                return
            }
            SerialPortManager.readbuffer = data
        }
    }
    
}

// 定義通知名稱
extension Notification.Name {
    static let serialPortDidReadData = Notification.Name("serialPortDidReadData")
}

