//
//  CustomTableCellView.swift
//  NuMicro ISP Programming Tool
//
//  Created by MS70MAC on 2024/4/23.
//

import Cocoa

class CustomTableCellView: NSTableCellView {
    
    @IBOutlet weak var customTextField: NSTextField!
    

    @IBOutlet weak var ComboBox: NSComboBox!
    
    @IBOutlet weak var titleText: NSTextField!
    
    var textHight:CGFloat = 0
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    func adjustTextFieldHeight() {
        let maxSize = CGSize(width: customTextField.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let textHeight = customTextField.attributedStringValue.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height
        //            customTextField.preferredMaxLayoutWidth = customTextField.bounds.width
        customTextField.frame.size.height = textHeight
        textHight = textHeight
    }
    
    func calculateHeight() -> CGFloat {
        //           let textFieldSize = customTextField.cell?.cellSize(forBounds: customTextField.bounds)
        //           let height = textFieldSize?.height ?? 0
        return textHight + 80 // Add some padding if needed
    }
    
}

class CustomComboBoxCell: NSComboBoxCell {
    
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        var newRect = super.drawingRect(forBounds: rect)
        
        if let stringValue = self.stringValue as NSString? {
            let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)]
            let size = stringValue.size(withAttributes: attributes)
            
            // 如果文字長度超過了 ComboBox 的寬度，則調整字型大小
            if size.width > newRect.width {
                let scale = newRect.width / size.width
                let newFontSize = (self.font?.pointSize ?? NSFont.systemFontSize) * scale
                self.font = NSFont.systemFont(ofSize: newFontSize)
                newRect = super.drawingRect(forBounds: rect)
            }
        }
        
        return newRect
    }
}
