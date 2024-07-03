//
//  FileManager.swift
//  NuMicro ISP Programming Tool
//
//  Created by MS70MAC on 2024/4/10.
//

import Foundation

// MARK: - JsonData Methods
struct FileData {
    var uri: URL
    var name: String
    var path: String
    var type: String
    var file: URL
    var byteArray: [UInt8]
}

class ConnectChipData {
    var chipInfo: ChipInfoData
    var chipPdid: ChipPdidData

    init(chipInfo: ChipInfoData, chipPdid: ChipPdidData) {
        self.chipInfo = chipInfo
        self.chipPdid = chipPdid
    }
}

struct ChipInfoData: Codable {
    var AP_size: String?
    var DF_size: String?
    var RAM_size: String?
    var DF_address: String?
    var LD_size: String?
    var PDID: String?
    var name: String?
    var note: String?
}

struct ChipPdidData: Codable {
    var name: String?
    var PID: String?
    var series: String?
    var note: String?
    var jsonIndex: String?
}

// MARK: - JsonFileManager Methods
class JsonFileManager {
    
    static let shared = JsonFileManager()
    private init() {}
    
    private static let TAG = "JsonFileManager"
    
    private static var APROM_BIN: FileData? = nil
    private static var DATAFLASH_BIN: FileData? = nil
    private static var _cids = [ChipInfoData]()
    private static var _cpds = [ChipPdidData]()
    static var CONNECT_CHIP_DATA: ConnectChipData? = nil
    
    func loadChipInfoFile() -> String? {
        
        // 獲取「文件」資料夾路徑
        var filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        // 獲取「下載」資料夾路徑
//        var downloadsPath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
        
        // 追加資料夾名稱
        filePath.appendPathComponent("ISPTool/ChipFile")
        // 檢查資料夾是否存在，如果不存在則建立
        if !FileManager.default.fileExists(atPath: filePath.path) {
            do {
                try FileManager.default.createDirectory(at: filePath, withIntermediateDirectories: true, attributes: nil)
                print("資料夾建立成功")
            } catch {
                print("無法建立資料夾：\(error)")
            }
        }
        
        // 優先從下載資料夾中讀取 JSON 文件
        let downloadedJsonUrl = filePath.appendingPathComponent("chip_info.json")
        if FileManager.default.fileExists(atPath: downloadedJsonUrl.path) {
            do {
                let jsonData = try Data(contentsOf: downloadedJsonUrl)
                let json = String(data: jsonData, encoding: .utf8)
                let chipInfoDatas = try JSONDecoder().decode([ChipInfoData].self, from: jsonData)
                JsonFileManager._cids = chipInfoDatas
                return json
            } catch {
                print("Error reading downloaded file: \(error)")
            }
        }
        
        // 如果下載資料夾中沒有 JSON 文件，則從 Bundle 中讀取 JSON 文件
        if let path = Bundle.main.path(forResource: "chip_info", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
                let json = String(data: jsonData, encoding: .utf8)
                let chipInfoDatas = try JSONDecoder().decode([ChipInfoData].self, from: jsonData)
                JsonFileManager._cids = chipInfoDatas
                
                // 複製 Bundle 中的 JSON 文件到下載資料夾
                let destinationUrl = filePath.appendingPathComponent("chip_info.json")
                try FileManager.default.copyItem(at: URL(fileURLWithPath: path), to: destinationUrl)
                print("已成功複製 JSON 文件到下載資料夾")
                
                return json
            } catch {
                print("Error reading file from Bundle: \(error)")
            }
        }
        
        return nil
    }
    
    func loadChipPdidFile() -> String? {
        
        // 獲取「文件」資料夾路徑
        var filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        // 獲取「下載」資料夾路徑
//        var downloadsPath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
        
        // 追加資料夾名稱
        filePath.appendPathComponent("ISPTool/ChipFile")
        // 檢查資料夾是否存在，如果不存在則建立
        if !FileManager.default.fileExists(atPath: filePath.path) {
            do {
                try FileManager.default.createDirectory(at: filePath, withIntermediateDirectories: true, attributes: nil)
                print("資料夾建立成功")
            } catch {
                print("無法建立資料夾：\(error)")
            }
        }
        
        // 優先從下載資料夾中讀取 JSON 文件
        let downloadedJsonUrl = filePath.appendingPathComponent("chip_pdid.json")
        if FileManager.default.fileExists(atPath: downloadedJsonUrl.path) {
            do {
                let jsonData = try Data(contentsOf: downloadedJsonUrl)
                let json = String(data: jsonData, encoding: .utf8)
                let chipPdidDatas = try JSONDecoder().decode([ChipPdidData].self, from: jsonData)
                JsonFileManager._cpds = chipPdidDatas
                return json
            } catch {
                print("Error reading downloaded file: \(error)")
            }
        }
        
        // 如果下載資料夾中沒有 JSON 文件，則從 Bundle 中讀取 JSON 文件
        if let path = Bundle.main.path(forResource: "chip_pdid", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
                let json = String(data: jsonData, encoding: .utf8)
                let chipPdidDatas = try JSONDecoder().decode([ChipPdidData].self, from: jsonData)
                JsonFileManager._cpds = chipPdidDatas
                
                // 複製 Bundle 中的 JSON 文件到下載資料夾
                let destinationUrl = filePath.appendingPathComponent("chip_pdid.json")
                try FileManager.default.copyItem(at: URL(fileURLWithPath: path), to: destinationUrl)
                print("已成功複製 JSON 文件到下載資料夾")
                
                return json
            } catch {
                print("Error reading file from Bundle: \(error)")
            }
        }
        
        return nil
    }

//    func loadChipPdidFile() -> String? {
//        let fileManager = FileManager.default
//        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let fileURL = documentsURL.appendingPathComponent("chip_pdid.json")
//
//        if fileManager.fileExists(atPath: fileURL.path) {
//            do {
//                let jsonData = try Data(contentsOf: fileURL)
//                let json = String(data: jsonData, encoding: .utf8)
//                let chipInfoDatas = try JSONDecoder().decode([ChipPdidData].self, from: jsonData)
//                JsonFileManager._cpds = chipInfoDatas
//                return json
//            } catch {
//                AppDelegate.print("Error reading file: \(error)")
//            }
//        } else {
//            if let path = Bundle.main.path(forResource: "chip_pdid", ofType: "json") {
//                do {
//                    let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
//                    let json = String(data: jsonData, encoding: .utf8)
//                    let chipInfoDatas = try JSONDecoder().decode([ChipPdidData].self, from: jsonData)
//                    JsonFileManager._cpds = chipInfoDatas
//                    return json
//                } catch {
//                    AppDelegate.print("Error reading file: \(error)")
//                }
//            }
//        }
//
//        return nil
//    }
    
    func saveFile(chipInfoFile: String, chipPdidFile: String) {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let binPath = documentsURL?.appendingPathComponent("ISPTool")

        if let binPath = binPath {
            do {
                try FileManager.default.createDirectory(at: binPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                AppDelegate.print("Error creating directory: \(error)")
            }

            // Save chip_pdid.json
            let pdidFileURL = binPath.appendingPathComponent("chip_pdid.json")
            if !FileManager.default.fileExists(atPath: pdidFileURL.path) {
                do {
                    try chipPdidFile.write(to: pdidFileURL, atomically: true, encoding: .utf8)
                } catch {
                    AppDelegate.print("Error writing chip_pdid.json file: \(error)")
                }
            }

            // Save chip_info.json
            let infoFileURL = binPath.appendingPathComponent("chip_info.json")
            if !FileManager.default.fileExists(atPath: infoFileURL.path) {
                do {
                    try chipInfoFile.write(to: infoFileURL, atomically: true, encoding: .utf8)
                } catch {
                    AppDelegate.print("Error writing chip_info.json file: \(error)")
                }
            }

            // Create Config directory
            let configPath = binPath.appendingPathComponent("Config")
            if !FileManager.default.fileExists(atPath: configPath.path) {
                do {
                    try FileManager.default.createDirectory(at: configPath, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    AppDelegate.print("Error creating Config directory: \(error)")
                }
            }
        }
    }

    
    func getChipInfoByPDID(deviceID: String) -> ConnectChipData? {
        let id = "0x\(deviceID)"
        var hasInfo = false
        var hasPdid = false

        var cid:ChipInfoData? = nil
        var cpd:ChipPdidData? = nil
        
        for c in JsonFileManager._cids {
            if c.PDID == id {
                hasInfo = true
                cid = c
            }
        }
        for c in JsonFileManager._cpds {
            if c.PID == id {
                hasPdid = true
                cpd = c
            }
        }

        if !hasInfo || !hasPdid {
            return nil
        }
        
        JsonFileManager.CONNECT_CHIP_DATA = ConnectChipData(chipInfo: cid!, chipPdid: cpd!)
        
        return JsonFileManager.CONNECT_CHIP_DATA
    }

    func getNameByUri(uri: URL?) -> String {
        guard let uri = uri else {
            return "null"
        }

        var result = "N/A"

        // if uri is file URL
        if uri.scheme == "file" {
            result = uri.lastPathComponent
        }

        return result
    }

    
}
