//
//  ViewController.swift
//  NuMicro ISP Programming Tool
//
//  Created by MS70MAC on 2024/3/5.
//

import Cocoa
import USBDeviceSwift

enum NulinkInterfaceType: UInt8 {
    case usb = 0x00
    // case hid = 0x01 // HID 和 UART 不能同时使用相同的值
    //    case uart = 0x00
    case spi = 0x03
    case i2c = 0x04
    case rs485 = 0x05
    case can = 0x06
    case wifi = 0x07
    case ble = 0x08
}

enum ViewStase: UInt8 {
    case viewDidLoad = 0
    case startBurn = 1
    case connected = 2
}

class ViewController: NSViewController {
    
    // MARK: - 元件宣告
    @IBOutlet weak var connectState_Label: NSTextField!
    @IBOutlet weak var nuMker_Label: NSTextField!
    @IBOutlet weak var connect_Button: NSButtonCell!
    @IBOutlet weak var interfaecType_ComboBox: NSComboBox!
    @IBOutlet weak var scanPort_NSComboBox: NSComboBox!
    @IBOutlet weak var nuMkerInfo_Label: NSTextField!
    @IBOutlet weak var DataFlash_File_Label: NSTextField!
    @IBOutlet weak var APROM_File_Label: NSTextField!
    @IBOutlet weak var DataFlash_FileData_Text: NSTextView!
    @IBOutlet weak var APROM_FileData_Text: NSTextView!
    @IBOutlet weak var EraseAll_Burn_check: NSButton!
    @IBOutlet weak var RestRun_Burn_Check: NSButton!
//    @IBOutlet weak var Config_Burn_Check: NSButton!
    @IBOutlet weak var APROM_Burn_Check: NSButton!
    @IBOutlet weak var DataFlash_Burn_Check: NSButton!
    @IBOutlet weak var StartBurn_Button: NSButton!
    @IBOutlet weak var Setting_Button: NSButton!
    @IBOutlet weak var DataFlash_Button: NSButton!
    @IBOutlet weak var APROM_Button: NSButton!
    @IBOutlet weak var Progress: NSProgressIndicator!
    
    @IBOutlet weak var config_0_Label: NSTextField!
    @IBOutlet weak var config_1_Label: NSTextField!
    @IBOutlet weak var config_2_Label: NSTextField!
    @IBOutlet weak var config_3_Label: NSTextField!
 
    @IBOutlet weak var ProgressNum_label: NSTextField!
    @IBOutlet weak var ProgressInfo_label: NSTextField!
    
    // MARK: - 宣告
    var INTERFACE_TYPE : NulinkInterfaceType = .usb
    var devices:[RFDevice] = []
    var connectedDeviceData:ConnectChipData? = nil
    var apromBinData : Data? = nil
    var apromMaxSize : Int = 0
    var dataFlashBinData : Data? = nil
    var dataFlashMaxSize : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ispManager = ISPManager.shared
        
        //宣告接收HID事件通知
        NotificationCenter.default.addObserver(self, selector: #selector(self.usbConnected), name: .HIDDeviceConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.usbDisconnected), name: .HIDDeviceDisconnected, object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(self.hidReadData), name: .HIDDeviceDataReceived, object: nil)
        // 監聽 MyTabViewControllerClosed 通知
        NotificationCenter.default.addObserver(self, selector: #selector(tabViewClosed), name: NSNotification.Name("MyTabViewClosed"), object: nil)
          
        
        self.setView(stase: .viewDidLoad)
        
        self.initChipInfoData()
        
    }
    
    @objc func tabViewClosed() {
        // 在這裡處理 MyTabViewController 關閉的事件
        ISPManager.shared.sendCMD_READ_CONFIG { restBf, isChecksum, isTimeout in
            if(restBf == nil){
                return
            }
            
            let displayConfig0 = ISPCommandTool.toDisplayComfig0(readBuffer: restBf!)
            let displayConfig1 = ISPCommandTool.toDisplayComfig1(readBuffer: restBf!)
            let displayConfig2 = ISPCommandTool.toDisplayComfig2(readBuffer: restBf!)
            let displayConfig3 = ISPCommandTool.toDisplayComfig3(readBuffer: restBf!)
            self.config_0_Label.stringValue = "0x\(displayConfig0)"
            self.config_1_Label.stringValue = "0x\(displayConfig1)"
            self.config_2_Label.stringValue = "0x\(displayConfig2)"
            self.config_3_Label.stringValue = "0x\(displayConfig3)"
        
        }
    }
    
    func initChipInfoData() {
        // 讀取 JSON 檔案
        let jfm = JsonFileManager.shared
        let infoJson = jfm.loadChipInfoFile()
        let pdidJson = jfm.loadChipPdidFile()
        if(infoJson == nil || pdidJson == nil){
            AppDelegate.print("Failed to load JSON files")
            return
        }
        
        // 儲存檔案
        jfm.saveFile(chipInfoFile: infoJson!, chipPdidFile: pdidJson!)
        
    }
    
    //更新畫面
    func setView(stase:ViewStase){
        DispatchQueue.main.async {
            
            switch(stase){
            case .connected:
                self.EraseAll_Burn_check.isEnabled = true
                self.RestRun_Burn_Check.isEnabled = true
//                self.Config_Burn_Check.isEnabled = true
                self.DataFlash_Burn_Check.isEnabled = self.dataFlashMaxSize != 0
                self.APROM_Burn_Check.isEnabled = true
                self.connect_Button.isEnabled = true
                self.StartBurn_Button.isEnabled = true
                self.Setting_Button.isEnabled = true
                self.DataFlash_Button.isEnabled = self.dataFlashMaxSize != 0
                self.APROM_Button.isEnabled = true
                break
            case .startBurn:
                self.EraseAll_Burn_check.isEnabled = false
                self.RestRun_Burn_Check.isEnabled = false
//                self.Config_Burn_Check.isEnabled = false
                self.DataFlash_Burn_Check.isEnabled = false
                self.APROM_Burn_Check.isEnabled = false
                self.connect_Button.isEnabled = false
                self.StartBurn_Button.isEnabled = false
                self.Setting_Button.isEnabled = false
                self.DataFlash_Button.isEnabled = false
                self.APROM_Button.isEnabled = false
                break
            case .viewDidLoad:
                self.EraseAll_Burn_check.isEnabled = false
                self.RestRun_Burn_Check.isEnabled = false
//                self.Config_Burn_Check.isEnabled = false
                self.DataFlash_Burn_Check.isEnabled = false
                self.APROM_Burn_Check.isEnabled = false
                self.connect_Button.isEnabled = true
                self.connect_Button.title = "Connect"
                self.connectState_Label.stringValue = "Disconnected"
                self.connectState_Label.textColor = NSColor.red
                self.nuMker_Label.stringValue=""
                ISPManager.connectedDevice = nil
                self.StartBurn_Button.isEnabled = false
                self.Setting_Button.isEnabled = false
                self.DataFlash_Button.isEnabled = false
                self.APROM_Button.isEnabled = false
                self.interfaecType_ComboBox?.selectItem(at: 0)
                if(self.interfaecType_ComboBox.indexOfSelectedItem == 0){
                    self.scanPort_NSComboBox.isEnabled = false
                    self.Progress.doubleValue = 0
                    self.Progress.startAnimation(nil)
                }
                self.config_0_Label.stringValue=""
                self.config_1_Label.stringValue=""
                self.config_2_Label.stringValue=""
                self.config_3_Label.stringValue=""
                self.nuMkerInfo_Label.stringValue = ""
                self.DataFlash_File_Label.stringValue = ""
                self.APROM_File_Label.stringValue = ""
                self.apromBinData = nil
                self.dataFlashBinData = nil
                break
            }
            
        }
    }
    // MARK: - onClick Methods
    
    //Connect button onClick
    @IBAction func BT_connect_onClick(_ sender: NSButton) {
        DispatchQueue.main.async {
            
            if (self.devices.count <= 0){
                return
            }
            
            if( ISPManager.connectedDevice != nil){
                self.setView(stase: .viewDidLoad)
                return
            }
            
            //開始連線
            self.connect_Button.title = "Disconnect"
            self.connectState_Label.stringValue = "Connected"
            self.connectState_Label.textColor = NSColor.systemGreen
            ISPManager.connectedDevice = self.devices[0] //選定 connected Device
            
            
            //            let data = Data(ISPCommandTool.toCMD(cmd: ISPCommands.CMD_CONNECT, packetNumber: 0))
            //            ISPManager.connectedDevice?.write(data)
            
            let ispManager = ISPManager.shared
            ispManager.sendCMD_CONNECT { respBf, isChecksum, isTimeout in
                
                if(respBf == nil || isChecksum == false || isTimeout == true){
                    //非新唐目標版時//isTimeout
                    return
                }
                
                self.setView(stase: .connected)
                
                ispManager.sendCMD_GET_DEVICEID { respBf, isChecksum, isTimeout  in
                    
                    if(respBf != nil){
                        let deviceID = ISPCommandTool.toDeviceID(readBuffer: respBf!)
                        self.connectedDeviceData = JsonFileManager.shared.getChipInfoByPDID(deviceID: deviceID)
                        self.nuMker_Label.stringValue = (self.connectedDeviceData?.chipPdid.name)!
                        self.nuMker_Label.textColor = NSColor.systemGreen
                        self.nuMkerInfo_Label.stringValue = "APROM：\(self.connectedDeviceData!.chipInfo.AP_size)\nData：\(self.connectedDeviceData!.chipInfo.DF_size)\nFw Ver：unknown"
                        AppDelegate.print("DEVICEID:\(ISPCommandTool.toDeviceID(readBuffer: respBf!))")
                        
                        //apromMaxSize
                        let AP_size = self.connectedDeviceData!.chipInfo.AP_size
                        var components = AP_size.components(separatedBy: "*")
                        if components.count == 2, let firstNumber = Int(components[0]), let secondNumber = Int(components[1]) {
                            let result = firstNumber * secondNumber
                            self.apromMaxSize = result
                        } else {
                            AppDelegate.print("AP_size Invalid input") // 如果輸入無效，則輸出錯誤信息
                        }
                        //dataFlashMaxSize
                        let DF_size = self.connectedDeviceData!.chipInfo.DF_size
                        components = DF_size.components(separatedBy: "*")
                        if components.count == 2, let firstNumber = Int(components[0]), let secondNumber = Int(components[1]) {
                            let result = firstNumber * secondNumber
                            self.dataFlashMaxSize = result
                            if(self.dataFlashMaxSize == 0){
                                self.DataFlash_Burn_Check.isEnabled = false
                            }
                        } else {
                            AppDelegate.print("DF_size Invalid input") // 如果輸入無效，則輸出錯誤信息
                        }
                        
                    }else{
                        self.nuMker_Label.stringValue = "unknown Device"
                        self.nuMker_Label.textColor = NSColor.red
                    }
                    AppDelegate.print("sendCMD_GET_DEVICEID:\(respBf?.toHexString()),\(isChecksum)")
                }
                
                ispManager.sendCMD_GET_FWVER { restBf, isChecksum, isTimeout in
                    if(restBf == nil){
                        return
                    }
                    let fwVer = ISPCommandTool.toFirmwareVersion(readBuffer: restBf!)
                    self.nuMkerInfo_Label.stringValue = "APROM：\(self.connectedDeviceData!.chipInfo.AP_size)\nData：\(self.connectedDeviceData!.chipInfo.DF_size)\nFw Ver：\(fwVer!)"
                }
                
                ispManager.sendCMD_READ_CONFIG { restBf, isChecksum, isTimeout in
                    if(restBf == nil){
                        return
                    }
                    
                    let displayConfig0 = ISPCommandTool.toDisplayComfig0(readBuffer: restBf!)
                    let displayConfig1 = ISPCommandTool.toDisplayComfig1(readBuffer: restBf!)
                    let displayConfig2 = ISPCommandTool.toDisplayComfig2(readBuffer: restBf!)
                    let displayConfig3 = ISPCommandTool.toDisplayComfig3(readBuffer: restBf!)
                    self.config_0_Label.stringValue = "0x\(displayConfig0)"
                    self.config_1_Label.stringValue = "0x\(displayConfig1)"
                    self.config_2_Label.stringValue = "0x\(displayConfig2)"
                    self.config_3_Label.stringValue = "0x\(displayConfig3)"
                    
                    // 讀取config json file
                    let series = self.connectedDeviceData!.chipPdid.series
                    let index = self.connectedDeviceData!.chipPdid.jsonIndex
                    let isLoadSuccess = ConfigManager.shared.readConfigFromFile( series: series, jsonIndex: index)
                    if(isLoadSuccess == false){
                        self.Setting_Button.isEnabled = false
                        let failureAlert = NSAlert()
                        failureAlert.messageText = "Setting functionality is disabled due to 'Failed to read config JSON file.' Please check the file and try again."
                        failureAlert.informativeText = "File not found"
                        failureAlert.alertStyle = .warning
                        failureAlert.addButton(withTitle: "OK")
                        failureAlert.runModal()
                        
                    }
                }
  
            }
            
        }
    }
    
    @IBAction func APROM_onClick(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowedFileTypes = ["bin"] // 只允許選擇 bin 檔案
        
        openPanel.begin { (result) in
            if result == .OK, let url = openPanel.url {
                let path = url.path // 檔案路徑
                let fileName = url.lastPathComponent // 檔案名稱
                DispatchQueue.main.async() {
                    self.APROM_File_Label.stringValue = (path)
                }
                AppDelegate.print("File Path: \(path)")
                AppDelegate.print("File Name: \(fileName)")
                do {
                    let fileData = try Data(contentsOf: url)
                    self.apromBinData = fileData
                    self.APROM_FileData_Text.string = fileData.toHexString()
                } catch {
                    AppDelegate.print("Error reading file: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @IBAction func DataFlash_onClick(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowedFileTypes = ["bin"] // 只允許選擇 bin 檔案
        
        openPanel.begin { (result) in
            if result == .OK, let url = openPanel.url {
                do {
                    let path = url.path // 檔案路徑
                    DispatchQueue.main.async() {
                        self.DataFlash_File_Label.stringValue = path
                    }
                    let fileData = try Data(contentsOf: url)
                    self.dataFlashBinData = fileData
                    self.DataFlash_FileData_Text.string = fileData.toHexString()
                } catch {
                    AppDelegate.print("Error reading file: \(error.localizedDescription)")
                }
            }
        }
    }
    
    //開始燒入
    @IBAction func StartBurn_onClick(_ sender: NSButton) {
        
        //檢查
        var isCheck = false
        let isAPROM = self.APROM_Burn_Check.state == .on
        let isDataFlash = self.DataFlash_Burn_Check.state == .on
        let isRestRun = self.RestRun_Burn_Check.state == .on
        let isEraseAll = self.EraseAll_Burn_check.state == .on
        
        if(self.APROM_Burn_Check.state == .on ){
            if(self.apromBinData == nil || self.apromBinData?.isEmpty == true){
                let Alert = NSAlert()
                Alert.messageText = "Please select an APROM bin file."
                Alert.alertStyle = .warning
                Alert.addButton(withTitle: "OK")
                Alert.runModal()
                return
            }
            if(self.apromBinData!.count > self.apromMaxSize){
                let Alert = NSAlert()
                Alert.messageText = "bin file size error."
                Alert.alertStyle = .warning
                Alert.addButton(withTitle: "OK")
                Alert.runModal()
                return
            }
            isCheck = true
        }
        if(self.DataFlash_Burn_Check.state == .on){
            if(self.dataFlashBinData == nil || self.dataFlashBinData?.isEmpty == true){
                let Alert = NSAlert()
                Alert.messageText = "Please select an DATA FLASH bin file."
                Alert.alertStyle = .warning
                Alert.addButton(withTitle: "OK")
                Alert.runModal()
                return
            }
            if(self.dataFlashBinData!.count > self.dataFlashMaxSize){
                let Alert = NSAlert()
                Alert.messageText = "bin file size error."
                Alert.alertStyle = .warning
                Alert.addButton(withTitle: "OK")
                Alert.runModal()
                return
            }
            isCheck = true
        }
        if(self.RestRun_Burn_Check.state == .on){
            isCheck = true
        }
        if(self.EraseAll_Burn_check.state == .on){
            isCheck = true
        }
        
        if(isCheck == false){
            let Alert = NSAlert()
            Alert.messageText = "Please select a burn-in function."
            Alert.alertStyle = .warning
            Alert.addButton(withTitle: "OK")
            Alert.runModal()
            return
        }
        
        self.setView(stase: .startBurn)
        
        let ispManager = ISPManager.shared
        var hasFailed = false
        var startTime: Date = Date()
        startTime = Date()
        
        //需要照順序 EraseALL> Config bit > APROM > DATAFLASH > Reset Run
        Thread {
            // Erase All
            if isEraseAll {
                DispatchQueue.main.async {self.ProgressInfo_label.stringValue = "Burn bin in Erase All..."}
                ispManager.sendCMD_ERASE_ALL(callback: { readArray, isCheckSum,timeout  in
                    if(readArray == nil){
                        DispatchQueue.main.async() {
                            let Alert = NSAlert()
                            Alert.messageText = "burn Erase All Failed."
                            Alert.alertStyle = .warning
                            Alert.addButton(withTitle: "OK")
                            Alert.runModal()
                        }
                        return
                    }
                    
                   
                })
            }
            
            // APROM
            if isAPROM  {
                
                DispatchQueue.main.async {self.ProgressInfo_label.stringValue = "Burn bin in APROM..."}
                ispManager.sendCMD_UPDATE_BIN(cmd: ISPCommands.CMD_UPDATE_APROM, sendByteArray: self.apromBinData!, startAddress: 0x00000000) { restBf, isFailed, progress in
                    AppDelegate.print("restBf:\(restBf?.toHexString())\nisFailed:\(isFailed)progress:\(progress) ")
                    
                    if(restBf == nil){
                        DispatchQueue.main.async() {
                            let Alert = NSAlert()
                            Alert.messageText = "burn APROM Failed."
                            Alert.alertStyle = .warning
                            Alert.addButton(withTitle: "OK")
                            Alert.runModal()
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.Progress.doubleValue = Double(progress)
                        self.ProgressNum_label.stringValue = "\(progress)%"
                    }
                    
                }
            }
            
            // DataFlash
            if isDataFlash {
                DispatchQueue.main.async {self.ProgressInfo_label.stringValue = "Burn bin in DataFlash..."}
                ispManager.sendCMD_UPDATE_BIN(cmd: ISPCommands.CMD_UPDATE_DATAFLASH, sendByteArray: self.dataFlashBinData!, startAddress: 0x00000000) { restBf, isFailed, progress in
                    AppDelegate.print("restBf:\(restBf?.toHexString())\nisFailed:\(isFailed)progress:\(progress) ")
                    
                    if(restBf == nil){
                        DispatchQueue.main.async() {
                            let Alert = NSAlert()
                            Alert.messageText = "burn DataFlash Failed."
                            Alert.alertStyle = .warning
                            Alert.addButton(withTitle: "OK")
                            Alert.runModal()
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.Progress.doubleValue = Double(progress)
                        self.ProgressNum_label.stringValue = "\(progress)%"
                    }
                }
            }
            
            // Reset and Run now
            if isRestRun  {
                DispatchQueue.main.async {self.ProgressInfo_label.stringValue = "Burn bin in Rest & Run..."}
                ispManager.sendCMD_RUN_APROM { restBf, isChecksum, isTimeout in
                    if(restBf == nil){
                        //送完就會斷線了
                        return
                    }
                }
            }

            DispatchQueue.main.async() {
                self.ProgressInfo_label.stringValue = "Burn complete."
                let endTime = Date()// 計算兩者之間的時間差
                let elapsedTime = endTime.timeIntervalSince(startTime)
                let formattedElapsedTime = String(format: "%.2f", elapsedTime)
                let Alert = NSAlert()
                Alert.messageText = "Burn Data is complete. Time: \(formattedElapsedTime)seconds"
                Alert.alertStyle = .informational
                Alert.addButton(withTitle: "OK")
                Alert.runModal()
                self.setView(stase: .connected)
//                self.Progress.doubleValue = Double(100)
            }
            
        }.start()
        
        
        
        
        
    }
    
    
    // MARK: - Notification Methods
    
    //連線HID裝置通知
    @objc func usbConnected(notification: NSNotification) {
        guard let nobj = notification.object as? NSDictionary else {
            return
        }
//
        guard let deviceInfo:HIDDevice = nobj["device"] as? HIDDevice else {
            return
        }
        let device = RFDevice(deviceInfo)
        DispatchQueue.main.async {
            self.devices.append(device)
            
        }
    }
    
    //HID裝置斷線通知
    @objc func usbDisconnected(notification: NSNotification) {
        
        guard let nobj = notification.object as? NSDictionary else {
            return
        }

        guard let productId:Int = nobj["productId"] as? Int else {
            return
        }
        
        DispatchQueue.main.async {
            if let index = self.devices.index(where: { $0.deviceInfo.productId == productId }) {
                self.devices.remove(at: index)
                if (productId == ISPManager.connectedDevice?.deviceInfo.productId) {
                    
                    DispatchQueue.main.async {
                        let Alert = NSAlert()
                        Alert.messageText = "USB Device disconnected"
                        Alert.alertStyle = .warning
                        Alert.addButton(withTitle: "OK")
                        Alert.runModal()
                        
                        self.setView(stase: .viewDidLoad)
                    }
                    
                    return
                }
            }
        }
        
    }
    
    
}

