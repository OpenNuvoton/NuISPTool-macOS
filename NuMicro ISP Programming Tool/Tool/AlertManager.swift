/*
 * Copyright 2026 Nuvoton Technology Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  AlertManager.swift
//  NuMicro ISP Programming Tool
//
//  Created by MS70MAC on 2024/7/3.
//

import Cocoa

import Cocoa

class AlertManager {
    static let shared = AlertManager()
    
    private var waitAlert: NSAlert?
    
    private init() {}
    
    func showMsg(title: String, msg: String, completion: ((Bool) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = msg
            alert.addButton(withTitle: "OK")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                completion?(true)
            }
        }
    }
    
    func showExecute(title: String, msg: String, completion: @escaping (Bool, Bool) -> Void) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = msg
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            switch response {
            case .alertFirstButtonReturn:
                completion(true, false)
            case .alertSecondButtonReturn:
                completion(false, true)
            default:
                completion(false, false)
            }
        }
    }
    
//    func startWait(title: String, msg: String) {
//        DispatchQueue.main.async {
//            let alert = NSAlert()
//            alert.messageText = title
//            alert.informativeText = msg
//            
//            let indicator = NSProgressIndicator()
//            indicator.style = .spinning
//            indicator.isIndeterminate = true
//            indicator.startAnimation(nil)
//            
//            alert.accessoryView = indicator
//            alert.window.styleMask.remove(.closable) // 移除關閉按鈕
//            alert.window.isMovable = false // 禁止移動
//            
//            self.waitAlert = alert
//            alert.runModal()
//        }
//    }
//    
//    func stopWait() {
//        DispatchQueue.main.async {
//            self.waitAlert?.window.close()
//            self.waitAlert = nil
//        }
//    }
}

//// 使用範例：
//
//AlertManager.shared.showMsg(title: "Error", msg: "Serial path open failed.", completion: nil)
//
//AlertManager.shared.showMsg(title: "Title", msg: "Error") { okClick in
//    // Todo-on ok click
//}
//
//AlertManager.shared.showExecute(title: "Title", msg: "Do you execute?") { okClick, cancelClick in
//    if okClick {
//        // Handle OK click
//    }
//    if cancelClick {
//        // Handle Cancel click
//    }
//}
//
//AlertManager.shared.startWait(title: "Loading", msg: "Please wait...")
//// 假設某個事件發生後停止等待
//AlertManager.shared.stopWait()
