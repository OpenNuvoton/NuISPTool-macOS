//
//  MyOutlineViewController.swift
//  NuMicro ISP Programming Tool
//
//  Created by MS70MAC on 2024/4/22.
//

import Foundation
import AppKit

class MyOutlineViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    @IBOutlet weak var outlineView: NSOutlineView!
    
    // Your data structure
    // 定義了一個包含水果和蔬菜的資料結構
    let data: [String: [String]] = [
        "Fruits": ["Apple", "Banana", "Orange"],
        "Vegetables": ["Carrot", "Tomato", "Lettuce"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 將 outlineView 的資料源和代理設置為自身
        outlineView.dataSource = self
        outlineView.delegate = self
    }
    
    // MARK: - NSOutlineViewDataSource
    
    // 返回指定項目的子項目數量
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? [String] {
            return item.count
        }
        return data.count
    }
    
    // 返回指定索引的子項目
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? [String] {
            return item[index]
        }
        return Array(data.keys)[index]
    }
    
    // 返回指定項目是否可以展開
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? [String] {
            return item.count > 0
        }
        return false
    }
    
    // 返回指定項目的值，用於顯示在列中
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return item as? String
    }
    
    // MARK: - NSOutlineViewDelegate
    
    // 返回指定項目是否可被選擇
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return false // Disable selection
    }
}
