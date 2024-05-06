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
