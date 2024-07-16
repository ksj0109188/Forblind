//
//  AppDIContainer.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import Foundation

final class AppDIContainer {
    lazy var appConfigurations = AppConfigurations()
    
    func makeDriveModeSceneDIContainer() -> DriveModeSceneDIContainer {
        let dependencies = DriveModeSceneDIContainer.Dependencies()

        return DriveModeSceneDIContainer(dependencies:  dependencies)
    }
}
