//
//  HexTool.swift
//  NuMicro ISP Programming Tool
//
//  Created by MS70MAC on 2024/5/21.
//

import Foundation

class HexTool {
    
    static func formatByteArray(data: [UInt8], format: Int) -> String {
        var formattedString = ""
        
        switch format {
        case 8:
            for i in stride(from: 0, to: data.count, by: 16) {
                let bytes = data[i..<min(i + 16, data.count)]
                let line = bytes.map { String(format: "%02X", $0) }.joined(separator: " ")
                formattedString += "\(String(format: "%08X", i)):  \(line)\n"
            }
        case 16:
            for i in stride(from: 0, to: data.count, by: 16) {
                let bytes = data[i..<min(i + 16, data.count)]
                let input = bytes.map { String(format: "%02X", $0) }.joined(separator: "")
                
                // 把字串按每兩個字元分割
                var components: [String] = []
                var currentIndex = input.startIndex
                
                while currentIndex < input.endIndex {
                    let endIndex = input.index(currentIndex, offsetBy: 2, limitedBy: input.endIndex) ?? input.endIndex
                    let substring = String(input[currentIndex..<endIndex])
                    components.append(substring)
                    currentIndex = endIndex
                }
                
                // 按每四個字元組合一次（即每兩個元素組合一次，注意組合順序）
                let processedComponents = stride(from: 0, to: components.count, by: 2).map { index -> String in
                    let endIndex = min(index + 2, components.count)
                    let subArray = components[index..<endIndex]
                    return subArray.reversed().joined()
                }
                
                // 組合結果並以空格分隔
                let v =  processedComponents.joined(separator: " ")
                
                formattedString += "\(String(format: "%08X", i)):  \(v)\n"
            }
        case 32:
            for i in stride(from: 0, to: data.count, by: 16) {
                let bytes = data[i..<min(i + 16, data.count)]
                let input = bytes.map { String(format: "%02X", $0) }.joined(separator: "")
                // 把字串按每兩個字元分割
                    var components: [String] = []
                    var currentIndex = input.startIndex
                    
                    while currentIndex < input.endIndex {
                        let endIndex = input.index(currentIndex, offsetBy: 2, limitedBy: input.endIndex) ?? input.endIndex
                        let substring = String(input[currentIndex..<endIndex])
                        components.append(substring)
                        currentIndex = endIndex
                    }
                    
                    // 按每八個字元組合一次（即每四個元素組合一次）
                let processedComponents = stride(from: 0, to: components.count, by :4).map { index -> String in
                        let endIndex = min(index + 4, components.count)
                        let subArray = components[index..<endIndex]
                        return subArray.reversed().joined()
                    }
                // 組合結果並以空格分隔
                let v =  processedComponents.joined(separator: " ")
                
                formattedString += "\(String(format: "%08X", i)):  \(v)\n"
            }
        default:
            print("Unsupported format")
            return ""
        }
        
        // 將格式化後的字串填入 self.APROM_FileData_Text.string
        return formattedString
    }
    
//    static func formatByteArray(data: [UInt8], bits: Int) -> String {
//        var result = ""
//        let bytesPerGroup = bits / 8
//        let bytesPerLine = 16
//        let bytesPerElement = 2
//        let formatString = "%02X"
//
//        for (index, byte) in data.enumerated() {
//            // Add new line every bytesPerLine
//            if index % bytesPerLine == 0 {
//                result += String(format: "\n%08X:  ", index)
//            }
//
//            // Add space every bytesPerGroup
//            if index % bytesPerGroup == 0 {
//                result += " "
//            }
//
//            // Add formatted byte
//            result += String(format: formatString, byte)
//
//            // Add space every bytesPerElement
//            if (index + 1) % bytesPerElement == 0 {
//                result += " "
//            }
//        }
//
//        return result
//    }
    

}


