//
//  ConfigJson.swift
//  NuMicro ISP Programming Tool
//
//  Created by MS70MAC on 2024/4/24.
//

import Foundation

// MARK: - JsonData Methods
// SubConfig
struct SubConfig: Codable {
    
    var name: String
    var description: String
    var offset: Int
    var length: Int
    var valuesIndex: Int? = 0
    var values: String
    var options: [String]
    var optionDescription: [String]
    var selectedOptionIndex: Int? = 0
    
    func toString() -> String {
        return "name: \(name), \n" +
                "description: \(description), \n" +
                "offset: \(offset), \n" +
                "length: \(length), \n" +
                "values: \(values), \n" +
                "=============== \n\n"
    }
}

// SubConfigSet
struct SubConfigSet: Codable {
    var index: Int
    var isEnable: Bool
    var subConfigs: [SubConfig]
    
    func toString() -> String {
        let subConfigString = subConfigs.map {
            "\($0.name) to \($0.values)\n"
        }.joined()
        return "ispConfig\(index): \(subConfigString)\n"
    }
}

// IspConfig
struct IspConfig: Codable {
    var series: String
    var subConfigSets: [SubConfigSet]
}
