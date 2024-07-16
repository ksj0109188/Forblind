//
//  PlaySongFlowCoordinatorDependencies.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import UIKit

protocol DriveModeFlowCoordinatorDependencies {
    func makeDriveModeViewController() -> DriveModeViewController
}

///note DriveMode의 화면 흐름을 정의한다.
final class DriveModeFlowCoordinator {
    private weak var navigationController: UINavigationController?
    private let dependencies: DriveModeFlowCoordinatorDependencies
    
    init(navigationController: UINavigationController? = nil, dependencies: DriveModeFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let actions = DriveModeViewModel.DriveModeViewModelActions()
        let vc = dependencies.makeDriveModeViewController()
        
        navigationController?.pushViewController(vc, animated: false)
    }
}
