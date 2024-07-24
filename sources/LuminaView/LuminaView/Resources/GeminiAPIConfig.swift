//
//  GeminiAPIConfig.swift
//  LuminaView
//
//  Created by 김성준 on 7/18/24.
//

import Foundation

struct GeminiAPIConfig {
    let apiKey: String
    let modelName: String
    
    init(apiKey: String, modelName: String) {
        self.apiKey = apiKey
        self.modelName = modelName
    }
}
