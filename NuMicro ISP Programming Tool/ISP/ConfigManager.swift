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
    
    var BIT_ARRAY: [[String]] = Array(repeating: [String](repeating: "0", count: 32), count: 12)
    
    // 從文件中讀取配置信息並初始化到全局變數 CONFIG_JSON_DATA 中
    func readConfigFromFile(series: String, jsonIndex: String?) -> Bool {
        
        // 獲取「下載」資料夾路徑
        var downloadsPath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
        // 追加資料夾名稱
        downloadsPath.appendPathComponent("ISPTool/Config")
        // 檢查資料夾是否存在，如果不存在則建立
        if !FileManager.default.fileExists(atPath: downloadsPath.path) {
            do {
                try FileManager.default.createDirectory(at: downloadsPath, withIntermediateDirectories: true, attributes: nil)
                print("資料夾建立成功")
            } catch {
                print("無法建立資料夾：\(error)")
                return false
            }
        }
        
        // 如果未提供 jsonIndex，則返回 false
        guard let jsonIndex = jsonIndex else {
            return false
        }
        
        // 優先從下載資料夾中讀取 JSON 文件
        let downloadedJsonUrl = downloadsPath.appendingPathComponent(jsonIndex.lowercased() + ".json")
        if FileManager.default.fileExists(atPath: downloadedJsonUrl.path) {
            // 讀取下載資料夾中的 JSON 文件
            do {
                let jsonData = try Data(contentsOf: downloadedJsonUrl)
                ConfigManager.CONFIG_JSON_DATA = try JSONDecoder().decode(IspConfig.self, from: jsonData)
                return true
            } catch {
                print("無法讀取下載資料夾中的 JSON 文件：\(error)")
                return false
            }
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
        
        // 複製 Bundle 中的 JSON 文件到下載資料夾
        do {
            try FileManager.default.copyItem(at: jsonUrl, to: downloadedJsonUrl)
            print("已成功複製 JSON 文件到下載資料夾")
        } catch {
            print("無法複製 JSON 文件到下載資料夾：\(error)")
        }
        
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
     * 將readBuffer更新到 CONFIG_LIST  ＆  BIT_ARRAY
     */
    func initReadBufferToConfigData(readBuffer: [UInt8]) {
        for i in 0..<12 {
            let configArray = [
                readBuffer[i * 4 + 8],
                readBuffer[i * 4 + 9],
                readBuffer[i * 4 + 10],
                readBuffer[i * 4 + 11]
            ]
            
            var intValue = configArray.withUnsafeBytes { $0.load(as: UInt32.self) }
            var binaryString = String(intValue, radix: 2)
            var stringArray = [String](repeating: "0", count: 32)
            for (index, char) in binaryString.reversed().enumerated() {
                stringArray[index] = String(char)
            }
            
            BIT_ARRAY[i] = stringArray
            
            if(i >= ConfigManager.CONFIG_JSON_DATA.subConfigSets.count){
                continue
            }
            
            //將respRead值更新到Data
            for j in 0...31 {
                for index in 0..<ConfigManager.CONFIG_JSON_DATA.subConfigSets[i].subConfigs.count {
                    var config = ConfigManager.CONFIG_JSON_DATA.subConfigSets[i].subConfigs[index]
                    if config.offset == j {
                        var values = ""
                        for l in 1...config.length {
                            values += stringArray[j+l-1]
                        }
                        ConfigManager.CONFIG_JSON_DATA.subConfigSets[i].subConfigs[index].values = values
                    }
                }
            }
        }
        
        AppDelegate.print("Read Config Binary: \(BIT_ARRAY)")
    }
    
    /**
     * 將readBuffer 轉換成12個 configUInts
     */
    func getConfigArray(readBuffer: [UInt8], callback: @escaping (_ configUInts: [UInt]) -> Void) {
        var configUInts: [UInt] = []
        
        for i in 0..<12 {
            let configArray = [
                readBuffer[i * 4 + 8],
                readBuffer[i * 4 + 9],
                readBuffer[i * 4 + 10],
                readBuffer[i * 4 + 11]
            ]
            
            // 將 bytes 轉換為 UInt32
            let intValue = configArray.withUnsafeBytes { $0.load(as: UInt32.self) }
            let configUInt = UInt(intValue)
            
            // 將 UInt32 值添加到 configUInts 陣列中
            configUInts.append(configUInt)
        }
        
        // 使用回調傳回 configUInts
        callback(configUInts)
    }
    
    //將list的值轉回[config]陣列（json內有幾個就轉幾個）
    func getConfigs(configList: [SubConfig], callback: @escaping (_ configUInts: [UInt]) -> Void) {
        var configUInts: [UInt] = []
        
        for i in 0..<ConfigManager.CONFIG_JSON_DATA.subConfigSets.count {
            var configBits = BIT_ARRAY[ConfigManager.CONFIG_JSON_DATA.subConfigSets[i].index]
            
            for j in 0..<32 {
                for setConfig in configList {
                    let subConfigs = ConfigManager.CONFIG_JSON_DATA.subConfigSets[i].subConfigs
                    for oldConfig in subConfigs where setConfig.offset == j && setConfig.name == oldConfig.name && setConfig.values != oldConfig.values {
                        for k in 1...setConfig.length {
                            let index = setConfig.values.index(setConfig.values.startIndex, offsetBy: k - 1)
                            configBits[j + k - 1] = String(setConfig.values[index])
                        }
                    }
                }
            }
            
            if let convertedUInt = UInt(configBits.reversed().joined(), radix: 2) {
                configUInts.append(convertedUInt)
                AppDelegate.print("config:\(String(format: "0x%08X", convertedUInt))")
            } else {
                AppDelegate.print("轉換失敗")
            }
        }
        
        callback(configUInts)
    }
    
}





