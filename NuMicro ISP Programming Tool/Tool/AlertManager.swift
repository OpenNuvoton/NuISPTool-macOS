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
