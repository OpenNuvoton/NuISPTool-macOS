//
//  ConfigManager.swift
//  NuMicro ISP Programming Tool
//
//  Created by MS70MAC on 2024/4/24.
//

import Foundation

class ConfigManager {
    
    // 單例實例
    static let shared = ConfigManager()
    
    private var TAG = "ConfigManager"
    static var CONFIG_JSON_DATA: IspConfig!
    private static var CONFIG_LIST = [SubConfig]()
    var BIT_ARRAY_0 = [String?](repeating: "0", count: 32)
    var BIT_ARRAY_1 = [String?](repeating: "0", count: 32)
    var BIT_ARRAY_2 = [String?](repeating: "0", count: 32)
    var BIT_ARRAY_3 = [String?](repeating: "0", count: 32)
    
    // 從文件中讀取配置信息並初始化到全局變數 CONFIG_JSON_DATA 中
    func readConfigFromFile(series: String, jsonIndex: String?) -> Bool {
        // 獲取文檔目錄的路徑
        var binpath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        // 追加文件名
        binpath.appendPathComponent("ISPTool/Config/\(series).json")
        
        // 檢查文件是否存在
        if FileManager.default.fileExists(atPath: binpath.path) {
            // 讀取文件內容到 Data 對象
            let jsonData = try! Data(contentsOf: binpath)
            // 使用 JSONDecoder 解析 Data 為 IspConfig 對象
            ConfigManager.CONFIG_JSON_DATA = try! JSONDecoder().decode(IspConfig.self, from: jsonData)
            return true
        }
        
        // 如果未提供 jsonIndex，則返回 false
        guard let jsonIndex = jsonIndex else {
            return false
        }
        
        // 根據 jsonIndex 加載 Bundle 中的 json 文件
        let filename = jsonIndex.lowercased()
        let resId = Bundle.main.url(forResource: filename, withExtension: "json")
        
        // 確保找到文件並讀取其內容
        guard let jsonUrl = resId, let jsonData = try? Data(contentsOf: jsonUrl) else {
            return false
        }
        
        // 使用 JSONDecoder 解析 Data 為 IspConfig 對象
        ConfigManager.CONFIG_JSON_DATA = try! JSONDecoder().decode(IspConfig.self, from: jsonData)
        return true
    }

    
    func getAllConfigList() -> [SubConfig] {
        ConfigManager.CONFIG_LIST.removeAll()
        
        for configArray in ConfigManager.CONFIG_JSON_DATA.subConfigSets {
            if configArray.isEnable == true {
                ConfigManager.CONFIG_LIST.append(contentsOf: configArray.subConfigs)
            }
        }
        
        return ConfigManager.CONFIG_LIST
    }
    
    /**
     * 將readBuffer更新到 CONFIG_0123_LIST BIT_ARRAY_0123
     */
    func initReadBufferToConfigData(readBuffer: [UInt8]) {
        let config_0_Array = [readBuffer[8], readBuffer[9], readBuffer[10], readBuffer[11]]
        let config_1_Array = [readBuffer[12], readBuffer[13], readBuffer[14], readBuffer[15]]
        let config_2_Array = [readBuffer[16], readBuffer[17], readBuffer[18], readBuffer[19]]
        let config_3_Array = [readBuffer[20], readBuffer[21], readBuffer[22], readBuffer[23]]
        
        // BIT_ARRAY_0 ------------------------------------------------------------------------------
        // 將bytearray轉換為整數
        var intValue = config_0_Array.withUnsafeBytes {$0.load(as: UInt32.self)}
        // 將整數轉換為二進制字串
        var binaryString = String(intValue, radix: 2)
        // 將二進制字串填充到 [String?] 陣列中
        var stringArray = [String?](repeating: "0", count: 32)
        for (index, char) in binaryString.reversed().enumerated() {
            stringArray[index] = String(char)
        }
        
        BIT_ARRAY_0 = stringArray
        
        for i in 0...31 {
            for index in 0..<ConfigManager.CONFIG_JSON_DATA.subConfigSets[0].subConfigs.count {
                var config = ConfigManager.CONFIG_JSON_DATA.subConfigSets[0].subConfigs[index]
                if config.offset == i {
                    var values = ""
                    for l in 1...config.length {
                        values += stringArray[i+l-1]!
                    }
                    ConfigManager.CONFIG_JSON_DATA.subConfigSets[0].subConfigs[index].values = values
                }
            }
        }
        
        // BIT_ARRAY_1 ------------------------------------------------------------------------------
        // 將bytearray轉換為整數
        intValue = config_1_Array.withUnsafeBytes {$0.load(as: UInt32.self)}
        // 將整數轉換為二進制字串
        binaryString = String(intValue, radix: 2)
        // 將二進制字串填充到 [String?] 陣列中
        stringArray = [String?](repeating: "0", count: 32)
        for (index, char) in binaryString.reversed().enumerated() {
            stringArray[index] = String(char)
        }
        
        BIT_ARRAY_1 = stringArray
        
        for i in 0...31 {
            for index in 0..<ConfigManager.CONFIG_JSON_DATA.subConfigSets[1].subConfigs.count {
                var config = ConfigManager.CONFIG_JSON_DATA.subConfigSets[1].subConfigs[index]
                if config.offset == i {
                    var values = ""
                    for l in 1...config.length {
                        values += stringArray[i+l-1]!
                    }
                    ConfigManager.CONFIG_JSON_DATA.subConfigSets[1].subConfigs[index].values = values
                }
            }
        }
        // BIT_ARRAY_2 ------------------------------------------------------------------------------
        // 將bytearray轉換為整數
        intValue = config_2_Array.withUnsafeBytes {$0.load(as: UInt32.self)}
        // 將整數轉換為二進制字串
        binaryString = String(intValue, radix: 2)
        // 將二進制字串填充到 [String?] 陣列中
        stringArray = [String?](repeating: "0", count: 32)
        for (index, char) in binaryString.reversed().enumerated() {
            stringArray[index] = String(char)
        }
        
        BIT_ARRAY_2 = stringArray
        
        for i in 0...31 {
            for index in 0..<ConfigManager.CONFIG_JSON_DATA.subConfigSets[2].subConfigs.count {
                var config = ConfigManager.CONFIG_JSON_DATA.subConfigSets[2].subConfigs[index]
                if config.offset == i {
                    var values = ""
                    for l in 1...config.length {
                        values += stringArray[i+l-1]!
                    }
                    ConfigManager.CONFIG_JSON_DATA.subConfigSets[2].subConfigs[index].values = values
                }
            }
        }
        
        // BIT_ARRAY_3 ------------------------------------------------------------------------------
        // 將bytearray轉換為整數
        intValue = config_3_Array.withUnsafeBytes {$0.load(as: UInt32.self)}
        // 將整數轉換為二進制字串
        binaryString = String(intValue, radix: 2)
        // 將二進制字串填充到 [String?] 陣列中
        stringArray = [String?](repeating: "0", count: 32)
        for (index, char) in binaryString.reversed().enumerated() {
            stringArray[index] = String(char)
        }
        
        BIT_ARRAY_3 = stringArray
        
        for i in 0...31 {
            for index in 0..<ConfigManager.CONFIG_JSON_DATA.subConfigSets[3].subConfigs.count {
                var config = ConfigManager.CONFIG_JSON_DATA.subConfigSets[3].subConfigs[index]
                if config.offset == i {
                    var values = ""
                    for l in 1...config.length {
                        values += stringArray[i+l-1]!
                    }
                    ConfigManager.CONFIG_JSON_DATA.subConfigSets[3].subConfigs[index].values = values
                }
            }
        }
        
        AppDelegate.print("Read Config Binary: \(BIT_ARRAY_0),\n \(BIT_ARRAY_1),\n \(BIT_ARRAY_2),\n \(BIT_ARRAY_3)")
    }
    
    func getConfigs(configList: [SubConfig],callback: @escaping (_ config0:UInt, _ config1:UInt, _ config2:UInt, _ config3:UInt) -> Void) {
        var array0 = BIT_ARRAY_0
        var array1 = BIT_ARRAY_1
        var array2 = BIT_ARRAY_2
        var array3 = BIT_ARRAY_3
        var config0Uint: UInt = 0
        var config1Uint: UInt = 0
        var config2Uint: UInt = 0
        var config3Uint: UInt = 0
        //config 0 ---------------------------------------------------------------------------------
        
        for i in 0...31 {
            for setConfig in configList {
                for oldConfig in ConfigManager.CONFIG_JSON_DATA.subConfigSets[0].subConfigs {
                    
                    if (setConfig.offset == i && setConfig.name == oldConfig.name && setConfig.values != oldConfig.values) {
                        for l in 1...setConfig.length {
                            let index = setConfig.values.index(setConfig.values.startIndex, offsetBy: l-1)
                            let value = String(setConfig.values[index])
                            array0[i+l-1] = value
                        }
                    }
                    
                }
            }
        }
        
        // 使用二進位轉十進位的方法將字串轉換為 UInt
        if let convertedUInt = UInt(array0.reversed().compactMap { $0 }.joined(), radix: 2) {
            config0Uint = convertedUInt
            AppDelegate.print(String(format: "0x%08X", config0Uint))
        } else {
            AppDelegate.print("轉換失敗")
        }

    
        
        //config 1 ---------------------------------------------------------------------------------
        for i in 0...31 {
            for setConfig in configList {
                for oldConfig in ConfigManager.CONFIG_JSON_DATA.subConfigSets[1].subConfigs {
                    
                    if (setConfig.offset == i && setConfig.name == oldConfig.name && setConfig.values != oldConfig.values) {
                        for l in 1...setConfig.length {
                            let index = setConfig.values.index(setConfig.values.startIndex, offsetBy: l-1)
                            let value = String(setConfig.values[index])
                            array1[i+l-1] = value
                        }
                    }
                    
                }
            }
        }
        // 使用二進位轉十進位的方法將字串轉換為 UInt
        if let convertedUInt = UInt(array1.reversed().compactMap { $0 }.joined(), radix: 2) {
            config1Uint = convertedUInt
            AppDelegate.print(String(format: "0x%08X", config1Uint))
        } else {
            AppDelegate.print("轉換失敗")
        }

        //config 2 ---------------------------------------------------------------------------------
        for i in 0...31 {
            for setConfig in configList {
                for oldConfig in ConfigManager.CONFIG_JSON_DATA.subConfigSets[2].subConfigs {
                    
                    if (setConfig.offset == i && setConfig.name == oldConfig.name && setConfig.values != oldConfig.values) {
                        for l in 1...setConfig.length {
                            let index = setConfig.values.index(setConfig.values.startIndex, offsetBy: l-1)
                            let value = String(setConfig.values[index])
                            array2[i+l-1] = value
                        }
                    }
                    
                }
            }
        }

        // 使用二進位轉十進位的方法將字串轉換為 UInt
        if let convertedUInt = UInt(array2.reversed().compactMap { $0 }.joined(), radix: 2) {
            config2Uint = convertedUInt
            AppDelegate.print(String(format: "0x%08X", config2Uint))
        } else {
            AppDelegate.print("轉換失敗")
        }

        //config 3 ---------------------------------------------------------------------------------
        for i in 0...31 {
            for setConfig in configList {
                for oldConfig in ConfigManager.CONFIG_JSON_DATA.subConfigSets[3].subConfigs {
                    
                    if (setConfig.offset == i && setConfig.name == oldConfig.name && setConfig.values != oldConfig.values) {
                        for l in 1...setConfig.length {
                            let index = setConfig.values.index(setConfig.values.startIndex, offsetBy: l-1)
                            let value = String(setConfig.values[index])
                            array3[i+l-1] = value
                        }
                    }
                    
                }
            }
        }
        
        // 使用二進位轉十進位的方法將字串轉換為 UInt
        if let convertedUInt = UInt(array3.reversed().compactMap { $0 }.joined(), radix: 2) {
            config3Uint = convertedUInt
            AppDelegate.print(String(format: "0x%08X", config3Uint))
        } else {
            AppDelegate.print("轉換失敗")
        }
        // ---------------------------------------------------------------------------------
//        AppDelegate.print("Config Uint: \(config0Uint), \(config1Uint), \(config2Uint), \(config3Uint)")



        callback(config0Uint, config1Uint, config2Uint, config3Uint)
    }
    
}


//class HEXTool {
//    static func bytesToUInt(_ bytes: [UInt8]) -> UInt {
//        var result: UInt = 0
//        for byte in bytes {
//            result = (result << 8) + UInt(byte)
//        }
//        return result
//    }
//
//    static func UIntTo32bitBinary(_ uint: UInt) -> [Int] {
//        var bits: [Int] = []
//        var value = uint
//        for _ in 0..<32 {
//            bits.insert(Int(value & 1), at: 0)
//            value >>= 1
//        }
//        return bits
//    }
//
//}




