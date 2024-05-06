//
//  ProgressAlert.swift
//  NuMicro ISP Programming Tool
//
//  Created by MS70MAC on 2024/4/19.
//

import Foundation
import Cocoa

class ProgressAlert {
    private var alert = NSAlert()
    private var progressBar = NSProgressIndicator()
    
    init(title: String, message: String) {
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        
        progressBar.style = .bar
        progressBar.isIndeterminate = false
        progressBar.minValue = 0
        progressBar.maxValue = 100
        progressBar.doubleValue = 0
        
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 50))
        progressBar.frame = NSRect(x: 20, y: 10, width: 160, height: 20)
        contentView.addSubview(progressBar)
        alert.accessoryView = contentView
    }
    
    func show() {
        alert.runModal()
    }
    
    func updateProgress(_ progress: Double) {
        progressBar.doubleValue = progress
    }
}

//// 使用範例
//let progressAlert = ProgressAlert(title: "正在處理", message: "請稍候...")
//progressAlert.show()
//
//// 假設某個處理過程，可以在進度條更新
//DispatchQueue.global().async {
//    for i in 0...100 {
//        DispatchQueue.main.async {
//            progressAlert.updateProgress(Double(i))
//        }
//        Thread.sleep(forTimeInterval: 0.1)
//    }
//}
