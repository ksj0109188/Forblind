//
//  AppDIContainer.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import Foundation

final class AppDIContainer {
    lazy var appConfigurations = AppConfigurations()
    lazy var guideService: GuideAPIWebRepository = {
        let config = WebSocketAPIConfig(url: appConfigurations.webSocketURL)
        
        return WebSocketRepository(config: config)
    }()
    
    func makeDriveModeSceneDIContainer() -> DriveModeSceneDIContainer {
        let dependencies = DriveModeSceneDIContainer.Dependencies(guideAPIWebRepository: guideService, cameraManager: CameraManger())

        return DriveModeSceneDIContainer(dependencies:  dependencies)
    }
}
