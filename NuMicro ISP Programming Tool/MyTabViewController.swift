//
//  File.swift
//  NuMicro ISP Programming Tool
//
//  Created by MS70MAC on 2024/4/22.
//

import Foundation
import AppKit
import Cocoa

class MyTabViewController: NSViewController,NSTableViewDelegate,NSTableViewDataSource {
    
    
    @IBOutlet weak var tableView: NSTableView!
    
    var configList: [SubConfig] = []
    var configList_Original: [SubConfig] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.selectionHighlightStyle = .none
        
        self.readConfig()
        
    }
    
    func readConfig() {
        
        let ispManager = ISPManager.shared
        
        ispManager.sendCMD_READ_CONFIG { restBf, isChecksum, isTimeout in
            if(isChecksum == false || isTimeout == true){
                return
            }
            ConfigManager.shared.initReadBufferToConfigData(readBuffer: restBf!)
            self.configList_Original = ConfigManager.shared.getAllConfigList()
            
            self.configList = self.configList_Original.map { $0 }//複製一份
            
            self.tableView.reloadData()
        }
        
    }
    
    @IBAction func UpdataButton(_ sender: NSButton) {
        
        var isChange = false
        for setConfig in self.configList {
            for origConfig in self.configList_Original{
                if setConfig.name == origConfig.name {
                    if(setConfig.values != origConfig.values){
                        isChange = true
                        break
                    }
                }
            }
        }
        if(isChange == false){
            let alert = NSAlert()
            alert.messageText = "Configuration settings were not modified.\nNo changes were written to the configuration file.\nClick OK to exit."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            
            let modalResponse = alert.runModal()
            
            // 判斷使用者是否按下了 OK 按鈕
            if modalResponse == .alertFirstButtonReturn {
                view.window?.close()
                // 發送一個通知給 ViewController，表示視窗已關閉
                NotificationCenter.default.post(name: NSNotification.Name("MyTabViewClosed"), object: nil)
            }
            return
        }
        
        let alert = NSAlert()
        alert.messageText = "Burn Configuration"
        alert.informativeText = "Do you want to burn the CONFIG into the DEVICE?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn { // OK button
            ConfigManager.shared.getConfigs(configList: self.configList) { config0, config1, config2, config3 in
                ISPManager.shared.sendCMD_UPDATE_CONFIG(config_0: config0, config_1: config1, config_2: config2, config_3: config3) { restBf, isChecksum, isTimeout in
                    
                    if(restBf != nil){
                        let completionAlert = NSAlert()
                        completionAlert.messageText = "Configuration successfully burned into the device."
                        completionAlert.informativeText = "Burn Complete"
                        completionAlert.alertStyle = .informational
                        completionAlert.addButton(withTitle: "OK")
                        let response = completionAlert.runModal()
                        if response == .alertFirstButtonReturn {
                            self.view.window?.close()
                            // 發送一個通知給 ViewController，表示視窗已關閉
                            NotificationCenter.default.post(name: NSNotification.Name("MyTabViewClosed"), object: nil)
                        }
                    }else{
                        let completionAlert = NSAlert()
                        completionAlert.messageText = "Failed to burn configuration into the device."
                        completionAlert.informativeText = "Burn Failed"
                        completionAlert.alertStyle = .informational
                        completionAlert.addButton(withTitle: "OK")
                        let response = completionAlert.runModal()
                        if response == .alertFirstButtonReturn {
                            self.view.window?.close()
                            // 發送一個通知給 ViewController，表示視窗已關閉
                            NotificationCenter.default.post(name: NSNotification.Name("MyTabViewClosed"), object: nil)
                        }
                    }
                }
            }
        }
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.configList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "myCell"), owner: nil) as! CustomTableCellView
        
        cell.titleText.stringValue = self.configList[row].name
        cell.customTextField.stringValue = self.configList[row].description
        
        cell.ComboBox.tag = row // 將行數作為標籤，用於識別是哪一行的下拉式選單
        cell.ComboBox.target = self
        cell.ComboBox.action = #selector(comboBoxDidChange(_:))
        
        // 清空 ComboBox 的所有 item
        cell.ComboBox.removeAllItems()
        cell.ComboBox.addItems(withObjectValues: self.configList[row].optionDescription)
        
        let values = self.configList[row].values
        for (index, option) in self.configList[row].options.enumerated() {//比對出values的index 並顯示正確的item
            if values == option {
                self.configList[row].valuesIndex = index
                self.configList[row].values =  self.configList[row].options[index]
                //                cell.ComboBox.stringValue = self.configList[row].optionDescription[index]
                cell.ComboBox.selectItem(at: index)
                break
            }
        }
        
        cell.adjustTextFieldHeight()
        return cell
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let cellIdentifier = NSUserInterfaceItemIdentifier("myCell")
        guard let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? CustomTableCellView else {
            return 50 // Default height
        }
        
        cell.titleText.stringValue = self.configList[row].name
        cell.customTextField.stringValue = self.configList[row].description
        cell.ComboBox.stringValue = self.configList[row].values
        cell.adjustTextFieldHeight()
        return cell.calculateHeight()
    }
    
    //下拉式選單點擊事件
    @objc func comboBoxDidChange(_ sender: NSComboBox) {
        let row = sender.tag
        let selectedOption = sender.stringValue
        
        for (index, option) in self.configList[row].optionDescription.enumerated() {
            if selectedOption == option {
                self.configList[row].valuesIndex = index
                self.configList[row].values =  self.configList[row].options[index]
                break
            }
        }
        
        AppDelegate.print("Row \(row) index:\(self.configList[row].valuesIndex!)  Selected values: <\(self.configList[row].values)>")
        AppDelegate.print("subConfigs[0].values:\(ConfigManager.CONFIG_JSON_DATA.subConfigSets[3].subConfigs[0].values)")
    }
}
