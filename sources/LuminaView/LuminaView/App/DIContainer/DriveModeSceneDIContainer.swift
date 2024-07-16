//
//  DriveModeSceneDIContainer.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import UIKit

final class DriveModeSceneDIContainer: DriveModeFlowCoordinatorDependencies {
    
    struct Dependencies {
        // MARK: API Service
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: UseCase
    // MARK: ViewModel
    func makeDriveModeViewModel() -> DriveModeViewModel {
        let viewModel = DriveModeViewModel(cameraManager: CameraManger(), actions: DriveModeViewModel.DriveModeViewModelActions())
        
        return viewModel
    }
    
    // MARK: Presentation
    func makeDriveModeViewController() -> DriveModeViewController {
        let vc = DriveModeViewController()
        
        return vc
    }
    
    func makeDriveModeSceneFlowCoordinator(navigationController: UINavigationController) -> DriveModeFlowCoordinator {
        DriveModeFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
}
