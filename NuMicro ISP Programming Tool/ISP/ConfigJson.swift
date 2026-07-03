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
