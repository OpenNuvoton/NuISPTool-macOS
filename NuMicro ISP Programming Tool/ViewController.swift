//
//  ViewController.swift
//  NuMicro ISP Programming Tool
//
//  Created by MS70MAC on 2024/3/5.
//

import Cocoa
import USBDeviceSwift
import SwiftSerial
import Foundation

enum ViewStase: UInt8 {
    case viewDidLoad = 0
    case startBurn = 1
    case connected = 2
    case connected_NoConfigJson = 3
    case startConnect = 4
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
    
    @IBOutlet weak var ProgressNum_label: NSTextField!
    @IBOutlet weak var ProgressInfo_label: NSTextField!
    
    @IBOutlet weak var Radio8bits: NSButton!
    @IBOutlet weak var Radio16bits: NSButton!
    @IBOutlet weak var Radio32bits: NSButton!
    
    @IBOutlet weak var configTitle0123: NSTextField!
    @IBOutlet weak var ConfigTitle4567: NSTextField!
    @IBOutlet weak var ConfigTitle891011: NSTextField!
    @IBOutlet weak var ConfigInfo_label: NSTextField!
    @IBOutlet weak var Config0: NSButton!
    @IBOutlet weak var Config1: NSButton!
    @IBOutlet weak var Config2: NSButton!
    @IBOutlet weak var Config3: NSButton!
    @IBOutlet weak var Config4: NSButton!
    @IBOutlet weak var Config5: NSButton!
    @IBOutlet weak var Config6: NSButton!
    @IBOutlet weak var Config7: NSButton!
    @IBOutlet weak var Config8: NSButton!
    @IBOutlet weak var Config9: NSButton!
    @IBOutlet weak var Config10: NSButton!
    @IBOutlet weak var Config11: NSButton!
    //    @IBOutlet weak var Config12: NSButton!
    //    @IBOutlet weak var Config13: NSButton!
    //    @IBOutlet weak var Config14: NSButton!
    //    @IBOutlet weak var Config15: NSButton!
    @IBOutlet var configButtons: [NSButton]!
    
    @IBOutlet weak var Indicator: NSProgressIndicator!
    // MARK: - 宣告
    var devices:[RFDevice] = []
    var serialDevices:[CleanFlightDevice] = []
    var connectedDeviceData:ConnectChipData? = nil
    var apromBinData : Data? = nil
    var apromMaxSize : Int = 0
    var dataFlashBinData : Data? = nil
    var dataFlashMaxSize : Int = 0
    var nowRadio : Int = 8
    var isLoadSuccess = false
    var serialDevicesPath :String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 將 configButtons 連接到 Interface Builder 中的對應按鈕
        configButtons = [Config0, Config1, Config2, Config3, Config4, Config5, Config6, Config7, Config8, Config9, Config10, Config11]
        // 為每個按鈕添加動作方法
        for button in configButtons {
            button.target = self
            button.action = #selector(buttonClicked(_:))
        }
        
        self.APROM_FileData_Text.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        self.DataFlash_FileData_Text.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        
        // 設置委託
        self.interfaecType_ComboBox.delegate = self
        self.scanPort_NSComboBox.delegate = self
        
        let ispManager = ISPManager.shared
        
        //宣告接收HID事件通知
        NotificationCenter.default.addObserver(self, selector: #selector(self.usbConnected), name: .HIDDeviceConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.usbDisconnected), name: .HIDDeviceDisconnected, object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(self.hidReadData), name: .HIDDeviceDataReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.serialDeviceAdded), name: .SerialDeviceAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.serialDeviceRemoved), name: .SerialDeviceRemoved, object: nil)
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
            
            self.updateConfigButtons(restBf: restBf!)
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
    
    func updateConfigButtons(restBf:[UInt8]) {
        for i in 0..<configButtons.count {
            let displayConfig = ISPCommandTool.toDisplayComfig(readBuffer: restBf, configNum: i)
            configButtons[i].title = "0x\(displayConfig)"
        }
        
        if(ConfigManager.CONFIG_JSON_DATA != nil){
            for i in 0..<ConfigManager.CONFIG_JSON_DATA.subConfigSets.count {
                if(ConfigManager.CONFIG_JSON_DATA.subConfigSets[i].isEnable == true){
                    configButtons[i].isEnabled = true
                }else{
                    configButtons[i].isEnabled = false
                }
                
            }
        }
    }
    
    //更新畫面
    func setView(stase:ViewStase){
        
        DispatchQueue.main.async() {
            
            self.ConfigInfo_label.cell?.alignment = .center
            
            switch(stase){
            case .connected:
                self.EraseAll_Burn_check.isEnabled = true
                self.RestRun_Burn_Check.isEnabled = true
                //                self.Config_Burn_Check.isEnabled = true
                self.DataFlash_Burn_Check.isEnabled = self.dataFlashMaxSize != 0
                self.APROM_Burn_Check.isEnabled = true
                self.connect_Button.isEnabled = true
                self.StartBurn_Button.isEnabled = true
                self.Setting_Button.isEnabled = self.isLoadSuccess == true
                self.DataFlash_Button.isEnabled = self.dataFlashMaxSize != 0
                self.APROM_Button.isEnabled = true
                self.ConfigInfo_label.isHidden = true
                for button in self.configButtons {
                    button.isHidden = false
                }
                self.configTitle0123.isHidden = false
                self.ConfigTitle4567.isHidden = false
                self.ConfigTitle891011.isHidden = false
                self.connect_Button.title = "Disconnect"
                self.connectState_Label.stringValue = "Connected"
                self.connectState_Label.textColor = NSColor.systemGreen
                self.Indicator.isHidden = true
                
                break
            case .startBurn:
                self.EraseAll_Burn_check.isEnabled = false
                self.RestRun_Burn_Check.isEnabled = false
                //                self.Config_Burn_Check.isEnabled = false
                self.DataFlash_Burn_Check.isEnabled = false
                self.APROM_Burn_Check.isEnabled = false
                self.connect_Button.isEnabled = false
                self.StartBurn_Button.isEnabled = false
                self.Setting_Button.isEnabled = self.isLoadSuccess == true
                self.DataFlash_Button.isEnabled = false
                self.APROM_Button.isEnabled = false
                self.Indicator.isHidden = false
                
                break
            case .viewDidLoad:
                self.interfaecType_ComboBox.isEnabled = true
                self.scanPort_NSComboBox.isEnabled = true
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
                self.Setting_Button.isEnabled = self.isLoadSuccess == true
                self.DataFlash_Button.isEnabled = false
                self.APROM_Button.isEnabled = false
                self.interfaecType_ComboBox?.selectItem(at: 0)
                if(self.interfaecType_ComboBox.indexOfSelectedItem == 0){
                    self.scanPort_NSComboBox.isEnabled = false
                    self.Progress.doubleValue = 0
                    self.Progress.startAnimation(nil)
                }
                self.Config0.stringValue=""
                self.Config1.stringValue=""
                self.Config2.stringValue=""
                self.Config3.stringValue=""
                self.nuMkerInfo_Label.stringValue = ""
                self.DataFlash_File_Label.stringValue = ""
                self.APROM_File_Label.stringValue = ""
                self.apromBinData = nil
                self.dataFlashBinData = nil
                self.ConfigInfo_label.isHidden = false
                self.ConfigInfo_label.stringValue = "Config information"
                for button in self.configButtons {
                    button.isHidden = true
                }
                self.configTitle0123.isHidden = true
                self.ConfigTitle4567.isHidden = true
                self.ConfigTitle891011.isHidden = true
                self.apromBinData = nil
                self.dataFlashBinData = nil
                self.APROM_FileData_Text.string = ""
                self.DataFlash_FileData_Text.string = ""
                self.Indicator.isHidden = true
                
                break
            case .connected_NoConfigJson:
                self.EraseAll_Burn_check.isEnabled = true
                self.RestRun_Burn_Check.isEnabled = true
                //                self.Config_Burn_Check.isEnabled = true
                self.DataFlash_Burn_Check.isEnabled = self.dataFlashMaxSize != 0
                self.APROM_Burn_Check.isEnabled = true
                self.connect_Button.isEnabled = true
                self.StartBurn_Button.isEnabled = true
                self.Setting_Button.isEnabled = self.isLoadSuccess == true
                self.DataFlash_Button.isEnabled = self.dataFlashMaxSize != 0
                self.APROM_Button.isEnabled = true
                self.ConfigInfo_label.isHidden = false
                for button in self.configButtons {
                    button.isHidden = true
                }
                self.configTitle0123.isHidden = true
                self.ConfigTitle4567.isHidden = true
                self.ConfigTitle891011.isHidden = true
                self.connect_Button.title = "Disconnect"
                self.connectState_Label.stringValue = "Connected"
                self.connectState_Label.textColor = NSColor.systemGreen
                self.Indicator.isHidden = true
                
                break
            case .startConnect:
                self.interfaecType_ComboBox.isEnabled = false
                self.scanPort_NSComboBox.isEnabled = false
                self.connect_Button.isEnabled = false
                self.Indicator.isHidden = false
                self.connectState_Label.stringValue = "Connecting"
                self.connectState_Label.textColor = NSColor.systemYellow
                self.Indicator.startAnimation(nil)
                
            }
            
        }
    }
    
    func isValidHex(_ value: String) -> Bool {
        let hexRegex = "^0x[0-9A-Fa-f]+$"
        let hexTest = NSPredicate(format: "SELF MATCHES %@", hexRegex)
        return hexTest.evaluate(with: value)
    }
    
    // MARK: - onClick Methods
    
    @IBAction func radioButtonClicked(_ sender: NSButton) {
        switch sender {
        case Radio8bits:
            print("8 bits selected")
            self.nowRadio = 8
            
        case Radio16bits:
            print("16 bits selected")
            self.nowRadio = 16
        case Radio32bits:
            print("32 bits selected")
            self.nowRadio = 32
        default:
            break
        }
        if(apromBinData != nil){
            self.APROM_FileData_Text.string = HexTool.formatByteArray(data: apromBinData!.toUint8Array, format: self.nowRadio)
        }
        if(dataFlashBinData != nil){
            self.DataFlash_FileData_Text.string = HexTool.formatByteArray(data: dataFlashBinData!.toUint8Array, format: self.nowRadio)
        }
    }
    
    //Config button Click
    @IBAction func buttonClicked(_ sender: NSButton) {
        if let index = configButtons.firstIndex(of: sender) {
            print("Config \(index) Button clicked")
            // 處理按鈕點擊事件
            
            let alert = NSAlert()
            alert.messageText = "Enter new config\(index) Hex word"
            alert.informativeText = "Warning! \nSubmitting this input will directly modify the configuration. \nPlease use with caution!"
            alert.alertStyle = .informational
            
            let inputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            inputTextField.placeholderString = configButtons[index].title
            inputTextField.stringValue = configButtons[index].title  // 預先填充的內容
            alert.accessoryView = inputTextField
            
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                let inputValue = inputTextField.stringValue
                if isValidHex(inputValue) {
                    print("Received hex input for Config \(index): \(inputValue)")
                    // 在這裡處理接收到的 Hex 值
                    
                    ISPManager.shared.sendCMD_READ_CONFIG { restBf, isChecksum, isTimeout in
                        if(restBf == nil){
                            return
                        }
                        
                        ConfigManager.shared.getConfigArray(readBuffer: restBf!) { configUInts in
                            
                            var configs:[UInt] = configUInts
                            // 去掉 "0x" 前綴
                            let hexValueString = String(inputValue.dropFirst(2))
                            // 使用基數 16 進行轉換
                            let uintValue = UInt(hexValueString, radix: 16)
                            
                            configs[index] = uintValue!
                            
                            ISPManager.shared.sendCMD_UPDATE_CONFIG(configs: configs) { restBf, isChecksum, isTimeout in
                                if(restBf == nil){
                                    //失敗
                                    return
                                }
                                self.updateConfigButtons(restBf: restBf!)
                            }
                        }
                    }
                    
                } else {
                    print("Invalid Hex input")
                    // 處理無效的 Hex 值
                    let alert = NSAlert()
                    alert.messageText = "Invalid Hex Input"
                    alert.informativeText = "The input you provided is not a valid Hex value. Please enter a valid Hex value."
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            }
            
        }
    }
    
    //open
    func openUartDevice() -> Bool {
        
        if (self.serialDevices.count <= 0 ){
            return false
        }
        
        let device = self.serialDevices[0]
        
        
        do {
            try device.openPort(toReceive: true, andTransmit: true)
        } catch PortError.failedToOpen {
            //                    self.dialogOK(question: "Error", text: "Serial port \(device.deviceInfo.path) failed to open.")
        } catch {
            //                    self.dialogOK(question: "Error", text: "\(error)")
        }
        ISPManager.connectedSerialDevice = device //選定連線的 device
        
        AppDelegate.print("path:\(String(describing: ISPManager.connectedSerialDevice?.deviceInfo.path))")
        AppDelegate.print("vendorId:\(String(describing: ISPManager.connectedSerialDevice?.deviceInfo.vendorId))")
        AppDelegate.print("productId:\(String(describing: ISPManager.connectedSerialDevice?.deviceInfo.productId))")
        AppDelegate.print("name:\(String(describing: ISPManager.connectedSerialDevice?.deviceInfo.name))")
        AppDelegate.print("serialNumber:\(String(describing: ISPManager.connectedSerialDevice?.deviceInfo.serialNumber))")
        AppDelegate.print("vendorName:\(String(describing: ISPManager.connectedSerialDevice?.deviceInfo.vendorName))")
        self.serialDevicesPath = ISPManager.connectedSerialDevice?.deviceInfo.path
        
        if (serialDevicesPath == nil){
            return false
        }
        
        let serialPortManager = SerialPortManager.shared
        if serialPortManager.open(portPath: serialDevicesPath!) {
            print("打開串列裝置\(serialDevicesPath!)")
            return true
        } else {
            print("無法打開串列裝置")
            return false
        }
    }
    
    //Connect button onClick
    @IBAction func BT_connect_onClick(_ sender: NSButton) {
  
        DispatchQueue.global().async {//開新執行緒
            
            // 更新 UI 到 startConnect 狀態
            self.setView(stase: .startConnect)
            
            if(ISPManager.INTERFACE_TYPE == .uart){
                //如果是UART
                if (ISPManager.connectedSerialDevice != nil || SerialPortManager.shared.isPortOpen()) {
                    
                    ISPManager.connectedSerialDevice = nil
                    SerialPortManager.shared.close()
                   
                    self.setView(stase: .viewDidLoad)
                    return
                }
                
                let isOpen = self.openUartDevice()
                if(isOpen == false){
                    AlertManager.shared.showMsg(title: "Error", msg: "Serial path open failed.", completion: nil)
                    
                    self.setView(stase: .viewDidLoad)
                    
                    return
                }
                
            }else{
                //其他HID介面
                if (self.devices.count <= 0 ){
                    AlertManager.shared.showMsg(title: "Info", msg: "No connectable Nuvoton Device found.", completion: nil)
                    self.setView(stase: .viewDidLoad)
                    return
                }
                
                //已連線的device
                if( ISPManager.connectedDevice != nil){
                    self.setView(stase: .viewDidLoad)
                    return
                }
                
                ISPManager.connectedDevice = self.devices[0] //選定 connected Device
                for d in self.devices{
                    if(ISPManager.INTERFACE_TYPE == .i2c || ISPManager.INTERFACE_TYPE == .spi || ISPManager.INTERFACE_TYPE == .rs485 ){
                        if( d.deviceInfo.productId == 16144){
                            ISPManager.connectedDevice = d //選定 connected Device
                            break
                        }
                    }
                    if(ISPManager.INTERFACE_TYPE == .usb  ){
                        if( d.deviceInfo.productId == 16128){
                            ISPManager.connectedDevice = d //選定 connected Device
                            break
                        }
                    }
                }
            }
            
            //        DispatchQueue.main.async {
            
            let ispManager = ISPManager.shared
            ispManager.sendCMD_CONNECT { respBf, isChecksum, isTimeout in
                
                if(isTimeout == true){
                    //沒有進入LDROM Timeout
                    AlertManager.shared.showMsg(title: "Info", msg: "Time Out. Please try resetting to enter LDROM ISP mode.", completion: nil)
                    self.setView(stase: .viewDidLoad)
                    return
                }
                
                if(respBf == nil || isChecksum == false){
                    //非新唐目標版時//isTimeout
                    AlertManager.shared.showMsg(title: "Error", msg: "This HID Device is not a Nuvoton Device, or Checksum failed.", completion: nil)
                    self.setView(stase: .viewDidLoad)
                    return
                }
                
                ispManager.sendCMD_GET_DEVICEID { respBf, isChecksum, isTimeout  in
                    
                    if(isChecksum == false || respBf == nil){
                        AlertManager.shared.showMsg(title: "Error", msg: "Get Divice info failed.", completion: nil)
                        return
                    }
                    
                    if(respBf != nil ){
                        DispatchQueue.main.async {
                            let deviceID = ISPCommandTool.toDeviceID(readBuffer: respBf!)
                            self.connectedDeviceData = JsonFileManager.shared.getChipInfoByPDID(deviceID: deviceID)
                            self.nuMker_Label.stringValue = (self.connectedDeviceData?.chipPdid.name)!
                            self.nuMker_Label.textColor = NSColor.systemGreen
                            self.nuMkerInfo_Label.stringValue = "APROM：\(self.connectedDeviceData!.chipInfo.AP_size!)\nData：\(self.connectedDeviceData!.chipInfo.DF_size!)\nFw Ver：unknown"
                            AppDelegate.print("DEVICEID:\(ISPCommandTool.toDeviceID(readBuffer: respBf!))")
                            
                            //apromMaxSize
                            let AP_size = self.connectedDeviceData!.chipInfo.AP_size
                            var components = AP_size!.components(separatedBy: "*")
                            if components.count == 2, let firstNumber = Int(components[0]), let secondNumber = Int(components[1]) {
                                let result = firstNumber * secondNumber
                                self.apromMaxSize = result
                            } else {
                                AppDelegate.print("AP_size Invalid input") // 如果輸入無效，則輸出錯誤信息
                            }
                            //dataFlashMaxSize
                            let DF_size = self.connectedDeviceData!.chipInfo.DF_size
                            components = DF_size!.components(separatedBy: "*")
                            if components.count == 2, let firstNumber = Int(components[0]), let secondNumber = Int(components[1]) {
                                let result = firstNumber * secondNumber
                                self.dataFlashMaxSize = result
                                if(self.dataFlashMaxSize == 0){
                                    self.DataFlash_Burn_Check.isEnabled = false
                                }
                            } else {
                                AppDelegate.print("DF_size Invalid input") // 如果輸入無效，則輸出錯誤信息
                            }
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.nuMker_Label.stringValue = "unknown Device"
                            self.nuMker_Label.textColor = NSColor.red
                        }
                    }
                    AppDelegate.print("sendCMD_GET_DEVICEID:\(respBf?.toHexString()),\(isChecksum)")
                    
                    ispManager.sendCMD_GET_FWVER { restBf, isChecksum, isTimeout in
                        if(restBf == nil){
                            AlertManager.shared.showMsg(title: "Error", msg: "Get FW Ver failed.", completion: nil)
                            return
                        }
                        DispatchQueue.main.async {
                            let fwVer = ISPCommandTool.toFirmwareVersion(readBuffer: restBf!)
                            self.nuMkerInfo_Label.stringValue = "APROM：\(self.connectedDeviceData!.chipInfo.AP_size!)\nData：\(self.connectedDeviceData!.chipInfo.DF_size!)\nFw Ver：\(fwVer!)"
                        }
                        
                        ispManager.sendCMD_READ_CONFIG { restBf, isChecksum, isTimeout in
                            if(restBf == nil){
                                AlertManager.shared.showMsg(title: "Error", msg: "Read congif failed.", completion: nil)
                                return
                            }
                            
                            // 讀取config json file
                            let series = self.connectedDeviceData!.chipPdid.series
                            let index = self.connectedDeviceData!.chipPdid.jsonIndex
                            self.isLoadSuccess = ConfigManager.shared.readConfigFromFile( series: series!, jsonIndex: index)
                            if(self.isLoadSuccess == false){
                                self.setView(stase: .connected_NoConfigJson)
                                DispatchQueue.main.async() {
                                    self.ConfigInfo_label.stringValue = "Config information Not displayed.\nFailed to read config \(series!) JSON file."
                                    AlertManager.shared.showMsg(title: "Info", msg: "Setting functionality is disabled due to 'Failed to read config JSON file.' Please check the file and try again.")
                                }
                                return
                            }
                            self.updateConfigButtons(restBf: restBf!)
                            self.setView(stase: .connected)
                        }
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
                    self.APROM_FileData_Text.string = HexTool.formatByteArray(data: fileData.toUint8Array, format: self.nowRadio)
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
                    self.DataFlash_FileData_Text.string = HexTool.formatByteArray(data: fileData.toUint8Array, format: self.nowRadio)
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
                if(self.isLoadSuccess){
                    self.setView(stase: .connected)
                }else{
                    self.setView(stase: .connected_NoConfigJson)
                }
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
    
    // 找到 Serial Device 通知
    @objc func serialDeviceAdded(notification: NSNotification) {
        guard let nobj = notification.object as? NSDictionary else {
            return
        }
        
        guard let deviceInfo:SerialDevice = nobj["device"] as? SerialDevice else {
            return
        }
        let device = CleanFlightDevice(deviceInfo)
        DispatchQueue.main.async {
            self.serialDevices.append(device)
            self.scanPort_NSComboBox.reloadData()
        }
    }
    
    // Serial Device 斷線通知
    @objc func serialDeviceRemoved(notification: NSNotification) {
        guard let nobj = notification.object as? NSDictionary else {
            return
        }
        
        guard let deviceInfo:SerialDevice = nobj["device"] as? SerialDevice else {
            return
        }
        DispatchQueue.main.async {
            if let index = self.serialDevices.index(where: { $0.deviceInfo.path == deviceInfo.path }) {
                self.serialDevices.remove(at: index)
                if (deviceInfo.path == ISPManager.connectedSerialDevice?.deviceInfo.path) {
                    
                    AlertManager.shared.showMsg(title: "Info", msg: "serial Device is Removed")
                    ISPManager.connectedSerialDevice = nil
                    ISPManager.connectedSerialDevice?.closePort()
                    SerialPortManager.shared.close()
                }
            }
            self.scanPort_NSComboBox.reloadData()
        }
        self.setView(stase: .viewDidLoad)
    }
    
}

extension ViewController: NSComboBoxDelegate,NSComboBoxDataSource {
    
    // NSComboBoxDelegate 方法
    func comboBoxSelectionDidChange(_ notification: Notification) {
        
        if notification.object as? NSComboBox == interfaecType_ComboBox {
            let selectedIndex = interfaecType_ComboBox.indexOfSelectedItem
            if selectedIndex == 0 {
                scanPort_NSComboBox.removeAllItems()
                scanPort_NSComboBox.addItems(withObjectValues: [""])
                self.scanPort_NSComboBox?.selectItem(at: 0)
                scanPort_NSComboBox.isEnabled = false
                
                updateConnectedDevice(interFace: .usb)
            }
            if selectedIndex == 1 {
                
                scanPort_NSComboBox.isEnabled = true
                scanPort_NSComboBox.removeAllItems()
                scanPort_NSComboBox.addItems(withObjectValues: ["SPI", "I2C", "RS485"])
                self.scanPort_NSComboBox?.selectItem(at: 0)
                updateConnectedDevice(interFace: .spi)
            }
            if selectedIndex == 2 {
                
                scanPort_NSComboBox.isEnabled = true
                scanPort_NSComboBox.removeAllItems()
                scanPort_NSComboBox.addItems(withObjectValues: ["UART"])
                self.scanPort_NSComboBox?.selectItem(at: 0)
                updateConnectedDevice(interFace: .uart)
            }
        }
        
        if notification.object as? NSComboBox == scanPort_NSComboBox {
            let interFaceIndex = interfaecType_ComboBox.indexOfSelectedItem
            let selectedIndex = scanPort_NSComboBox.indexOfSelectedItem
            if interFaceIndex == 1  {
                if selectedIndex == 0  {
                    updateConnectedDevice(interFace: .spi)
                }
                if selectedIndex == 1 {
                    updateConnectedDevice(interFace: .i2c)
                }
                if selectedIndex == 2 {
                    updateConnectedDevice(interFace: .rs485)
                }
            }
        }
        
    }
    
    // 更新 updateConnectedDevice
    func updateConnectedDevice(interFace:NulinkInterfaceType) {
        switch(interFace){
            
        case .usb:
            AppDelegate.print("interface: usb")
            ISPManager.INTERFACE_TYPE = .usb
            break
        case .spi:
            AppDelegate.print("interface: spi")
            ISPManager.INTERFACE_TYPE = .spi
            break
        case .i2c:
            AppDelegate.print("interface: i2c")
            ISPManager.INTERFACE_TYPE = .i2c
            break
        case .rs485:
            AppDelegate.print("interface: rs485")
            ISPManager.INTERFACE_TYPE = .rs485
            break
        case .can:
            AppDelegate.print("interface: can")
            ISPManager.INTERFACE_TYPE = .can
            break
        case .wifi:
            AppDelegate.print("interface: wifi")
            ISPManager.INTERFACE_TYPE = .wifi
            break
        case .ble:
            AppDelegate.print("interface: ble")
            ISPManager.INTERFACE_TYPE = .ble
            break
        case .uart:
            AppDelegate.print("interface: uart")
            ISPManager.INTERFACE_TYPE = .uart
            break
        }
    }
}
