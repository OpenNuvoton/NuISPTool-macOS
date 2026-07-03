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
//  AutoResizingTextField.swift
//  NuMicro ISP Programming Tool
//
//  Created by MS70MAC on 2024/4/22.
//

import Cocoa

class AutoResizingTextField: NSTextField {
    
    override var intrinsicContentSize: NSSize {
        let size = super.intrinsicContentSize
        let fittingSize = self.fittingSize
        return NSSize(width: size.width, height: fittingSize.height)
    }
    
    override var fittingSize: NSSize {
        let maxSize = NSSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let textStorage = NSTextStorage(string: stringValue)
        let textContainer = NSTextContainer(containerSize: maxSize)
        let layoutManager = NSLayoutManager()
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0
        layoutManager.glyphRange(for: textContainer)
        
        return layoutManager.usedRect(for: textContainer).size
    }
}
