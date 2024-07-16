//
//  File.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import Foundation

final class AppConfigurations {
    lazy var geminiAPIKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "geminiAPIKey") as? String else {
            fatalError("geminiAPIKey is nil")
        }
        return key
    }()
}
