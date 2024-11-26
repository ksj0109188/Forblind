//
//  AppFlowCoordinator.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import UIKit

///note: FlowCoordinator들을 관리
final class AppFlowCoordinator: Coordinator, DriveModeFlowCoordinatorDelegate {
    var children: [Coordinator]?
    var navigationController: UINavigationController
    private let appDIContainer: AppDIContainer
    
    init(navigationController: UINavigationController, appDIContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }
    
    func start(animated: Bool, onDismissed: (() -> Void)?) {
        presentDriveModeScene()
    }
    
    func presentDriveModeScene() {
        let driveModeSceneDIContainer = appDIContainer.makeDriveModeSceneDIContainer()
        let coordinator = driveModeSceneDIContainer.makeDriveModeSceneFlowCoordinator(navigationController: navigationController)
        children?.append(coordinator)
        
        presentChild(coordinator, animated: false)
    }
    
    func showLoginScene() {
        
    }
}
