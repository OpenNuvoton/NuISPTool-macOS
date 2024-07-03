//
//  ISPCommands.swift
//  NuMicro ISP Programming Tool
//
//  Created by MS70MAC on 2024/3/21.
//

import Foundation

enum ISPCommands: UInt {
    case CMD_REMAIN_PACKET = 0x00000000
    case CMD_UPDATE_APROM = 0x000000A0
    case CMD_UPDATE_CONFIG = 0x000000A1
    case CMD_READ_CONFIG = 0x000000A2
    case CMD_ERASE_ALL = 0x000000A3
    case CMD_SYNC_PACKNO = 0x000000A4
    case CMD_GET_FWVER = 0x000000A6
    case CMD_GET_DEVICEID = 0x000000B1
    case CMD_UPDATE_DATAFLASH = 0x000000C3
    case CMD_RUN_APROM = 0x000000AB
    case CMD_RUN_LDROM = 0x000000AC
    case CMD_RESET = 0x000000AD
    case CMD_CONNECT = 0x000000AE
    case CMD_RESEND_PACKET = 0x000000FF
    // Support SPI Flash
    case CMD_ERASE_SPIFLASH = 0x000000D0
    case CMD_UPDATE_SPIFLASH = 0x000000D1
}

enum ISPCanCommands: UInt {
    case CMD_CAN_READ_CONFIG = 0xA2000000
//    case CMD_CAN_UPDATE_APROM = 0xAB000000
    case CMD_CAN_GET_DEVICE = 0xB1000000
    case CMD_CAN_RUN_APROM = 0xAB000000
}

// MARK: - ISPCommandTool Methods
class ISPCommandTool {
    private static let TAG = "ISPCommandTool"

    static func toCMD(cmd: ISPCommands, packetNumber: UInt) -> [UInt8] {
        let cmdBytes = cmd.rawValue.UIntTo4Bytes()
        let packetNumberBytes = packetNumber.UIntTo4Bytes()
        let noneBytes: [UInt8] = Array(repeating: 0x00, count: 56)
        
        var sendBytes = [UInt8]()
        sendBytes += cmdBytes
        sendBytes += packetNumberBytes
        sendBytes += noneBytes

        return sendBytes
    }

    static func toChecksumBySendBuffer(sendBuffer: [UInt8]) -> UInt {
        var sendBuffer = sendBuffer
        sendBuffer[1] = 0x00 // 將不同 interface 所偷改的修正回來
        var sum: UInt = 0
        for byte in sendBuffer {
            sum += UInt(byte)
        }
        return sum
    }

    static func toChecksumByReadBuffer(readBuffer: [UInt8]) -> UInt {
        let bytes: [UInt8] = [readBuffer[0], readBuffer[1], readBuffer[2], readBuffer[3]]
        // 將每個元素轉換為對應的十進制數字
        let values = bytes.map { Int($0) }

        // 將數字按照 Little-endian 的順序組合起來，並轉換為十進制數字
        let result = values.enumerated().reduce(0) { (acc, tuple) in
            let (index, value) = tuple
            return acc + (value << (index * 8))
        }
        return UInt(result)
    }
    
    static func toPackNo(readBuffer: [UInt8]) -> UInt {
        let bytes: [UInt8] = [readBuffer[4], readBuffer[5], readBuffer[6], readBuffer[7]]
        // 將每個元素轉換為對應的十進制數字
        let values = bytes.map { Int($0) }

        // 將數字按照 Little-endian 的順序組合起來，並轉換為十進制數字
        let result = values.enumerated().reduce(0) { (acc, tuple) in
            let (index, value) = tuple
            return acc + (value << (index * 8))
        }
        return UInt(result)
    }
    
    static func toDeviceID(readBuffer: [UInt8]) -> String {
        let deviceIDArray: [UInt8] = [readBuffer[11], readBuffer[10], readBuffer[9], readBuffer[8]]
        return Data(deviceIDArray).toHexString()
    }

    static func toFirmwareVersion(readBuffer: [UInt8]) -> String? {
        let deviceIDArray: [UInt8] = [
            readBuffer[11], readBuffer[10], readBuffer[9], readBuffer[8]
        ]
        let deviceIDData = Data(deviceIDArray)
        let byte: UInt8 = readBuffer[8]
        let data = Data([byte])
        return data.toHexString()
    }
    
    static func toUpdataCongigeCMD(configs: [UInt], packetNumber: UInt) -> [UInt8] {

        let cmdBytes = ISPCommands.CMD_UPDATE_CONFIG.rawValue.UIntTo4Bytes()
        let packetNumberBytes = packetNumber.UIntTo4Bytes()
        
        var sendBytes: [UInt8] = []
        sendBytes += cmdBytes
        sendBytes += packetNumberBytes
        
        for config in configs {
            sendBytes += config.UIntTo4Bytes()
        }
        
        // 計算當前 sendBytes 長度並補足至 64 bytes
        let currentLength = sendBytes.count
        if currentLength < 64 {
            let paddingLength = 64 - currentLength
            let paddingBytes: [UInt8] = Array(repeating: 0x00, count: paddingLength)
            sendBytes += paddingBytes
        }
        
        print(sendBytes.toHexString())
        return sendBytes
    }

    
    static func toUpdataBin_CMD(cmd: ISPCommands, packetNumber: UInt, startAddress: UInt, size: Int, data: Data, isFirst: Bool) -> [UInt8] {
        var sendBytes = [UInt8]()
        
        if isFirst {
            // 第一次CMD
            let cmdBytes = cmd.rawValue.UIntTo4Bytes()
            let packetNumberBytes = packetNumber.UIntTo4Bytes()
            let addressBytes = startAddress.UIntTo4Bytes()
            let totalSizeBytes = UInt(size).UIntTo4Bytes()

            sendBytes += cmdBytes
            sendBytes += packetNumberBytes
            sendBytes += addressBytes
            sendBytes += totalSizeBytes
            sendBytes += data

        } else {
            // 剩下的CMD
            let cmdBytes = UInt(0x00000000).UIntTo4Bytes()
            let packetNumberBytes = packetNumber.UIntTo4Bytes()

            sendBytes += cmdBytes
            sendBytes += packetNumberBytes
            sendBytes += data

        }

        return sendBytes
    }

    static func toDisplayComfig(readBuffer: [UInt8], configNum: Int) -> String {
        let startIdx = 8 + 4 * configNum
        let deviceIDArray = [readBuffer[startIdx + 3], readBuffer[startIdx + 2], readBuffer[startIdx + 1], readBuffer[startIdx]]
        return deviceIDArray.toHexString()
    }

    
//    static func toDisplayComfig0(readBuffer: [UInt8]) -> String {
//        let deviceIDArray: [UInt8] = [readBuffer[11], readBuffer[10], readBuffer[9], readBuffer[8]]
//        return deviceIDArray.toHexString()
//    }
//
//    static func toDisplayComfig1(readBuffer: [UInt8]) -> String {
//        let deviceIDArray: [UInt8] = [readBuffer[15], readBuffer[14], readBuffer[13], readBuffer[12]]
//        return deviceIDArray.toHexString()
//    }
//
//    static func toDisplayComfig2(readBuffer: [UInt8]) -> String {
//        let deviceIDArray: [UInt8] = [readBuffer[19], readBuffer[18], readBuffer[17], readBuffer[16]]
//        return deviceIDArray.toHexString()
//    }
//
//    static func toDisplayComfig3(readBuffer: [UInt8]) -> String {
//        let deviceIDArray: [UInt8] = [readBuffer[23], readBuffer[22], readBuffer[21], readBuffer[20]]
//        return deviceIDArray.toHexString()
//    }

}

// MARK: - HEX Methods
extension UInt {
    func UIntTo4Bytes() -> [UInt8] {
        return [
            UInt8(self & 0xFF),
            UInt8((self >> 8) & 0xFF),
            UInt8((self >> 16) & 0xFF),
            UInt8((self >> 24) & 0xFF)
        ]
    }

    func UIntToUInt() -> UInt {
        return UInt(self)
    }
}

extension Array where Element == UInt8 {
    func toHexString() -> String {
        return self.map { String(format: "%02X", $0) }.joined()
    }
}

extension Data {
    func toHexString() -> String {
        return map { String(format: "%02X", $0) }.joined()
    }
    
    var toUint8Array: [UInt8] {
            return [UInt8](self)
        }
    
}
