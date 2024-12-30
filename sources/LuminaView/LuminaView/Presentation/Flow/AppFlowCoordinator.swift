//
//  AppFlowCoordinator.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import UIKit

final class AppFlowCoordinator: Coordinator, DriveModeFlowCoordinatorDelegate, LoginSceneFlowCoordinatorDelegate, PaymentSceneFlowCoordinatorDelegate {
    var children: [Coordinator]?
    var navigationController: UINavigationController
    private let appDIContainer: AppDIContainer
    
    init(navigationController: UINavigationController, appDIContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }
    
    func start(animated: Bool, onDismissed: (() -> Void)?) {
//        presentDriveModeScene()
        presentLoginScene()
    }
    
    func presentDriveModeScene() {
        let driveModeSceneDIContainer = appDIContainer.makeDriveModeSceneDIContainer()
        let coordinator = driveModeSceneDIContainer.makeDriveModeSceneFlowCoordinator(navigationController: navigationController,parentCoordinator: self)
        children?.append(coordinator)
        
        presentChild(coordinator, animated: false)
    }
    
    func presentLoginScene() {
        let loginSceneDIContainer = appDIContainer.makeLoginSceneDIContainer()
        let coordinator = loginSceneDIContainer.makeLoginSceneFlowCoordinator(navigationController: navigationController, parentCoordinator: self)
        children?.append(coordinator)
        
        presentChild(coordinator, animated: false)
    }
    
    func showPaymentScene() {
        let paymentDIContainer = appDIContainer.makePaymentDIContainer()
        let coordinaotr = paymentDIContainer.makePaymentSceneFlowCoordinator(navigationController: navigationController, parentCoordinator: self)
        children?.append(coordinaotr)
        
        presentChild(coordinaotr, animated: false)
    }
}
