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
    
    lazy var geminiModelName: String = {
        guard let modelName = Bundle.main.object(forInfoDictionaryKey: "geminiModelName") as? String else {
            fatalError("modelName is nil")
        }
        return modelName
    }()
    
    lazy var webSocketURL: String = {
        guard let requestProtocol = Bundle.main.infoDictionary?["WEB_SOCKET_PROTOCOL"] as? String,
              let host = Bundle.main.infoDictionary?["WEB_SOCKET_HOST"] as? String,
              let port = Bundle.main.infoDictionary?["WEB_SOCKET_PORT"] as? String,
              let path = Bundle.main.infoDictionary?["WEB_SOCKET_PATH"] as? String  else {
            fatalError("webSocketURL is nil")
        }
        return "\(requestProtocol)://\(host):\(port)/\(path)"
    }()
}
