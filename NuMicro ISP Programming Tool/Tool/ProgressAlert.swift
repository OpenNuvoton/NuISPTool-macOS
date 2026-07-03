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
