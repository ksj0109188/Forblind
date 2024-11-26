//
//  DriveModeSceneDIContainer.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import UIKit

final class DriveModeSceneDIContainer: DriveModeFlowCoordinatorDependencies {
    struct Dependencies {
        let guideAPIWebRepository: GuideAPIWebRepository
        let freeTrialRepository: FreeTrialRepository
        let userInfoRepository: UserInfoRepository
        let cameraManager: Recodable
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: Utilites
    func makeCameraManager() -> Recodable {
        return dependencies.cameraManager
    }
    
    // MARK: UseCase
    func makeDriveModeUsecase() -> FetchGuideUseCase {
        FetchGuideUseCase(guideAPIWebRepository: dependencies.guideAPIWebRepository)
    }
    
    func makeCheckFreeTrialUsecase() -> CheckFreeTrialUseCase {
        CheckFreeTrialUseCase(repository: dependencies.freeTrialRepository)
    }
    
    func makeUpdateFreeTrialUsecase() -> UpdateFreeTrialUseCase {
        UpdateFreeTrialUseCase(repository: dependencies.freeTrialRepository)
    }
    
    func makefetchUserInfoUseCase() -> FetchUserInfoUseCase {
        FetchUserInfoUseCase(repository: dependencies.userInfoRepository)
    }
    
    // MARK: ViewModel
    func makeDriveModeViewModel(actions: DriveModeViewModelActions) -> DriveModeViewModel {
        let viewModel = DriveModeViewModel(fetchGuideUseCase: makeDriveModeUsecase(), checkFreeTrialUseCase: makeCheckFreeTrialUsecase(), updateFreeTrialUseCase: makeUpdateFreeTrialUsecase(), fetchUserInfoUseCase: makefetchUserInfoUseCase(), cameraManager: makeCameraManager(), actions: actions)
        
        return viewModel
    }
    
    // MARK: Presentation
    func makeDriveModeViewController(actions: DriveModeViewModelActions) -> DriveModeViewController {
        let vc = DriveModeViewController()
        vc.create(viewModel: makeDriveModeViewModel(actions: actions))
        
        return vc
    }
    
    func makeCameraPreviewViewController(viewModel: DriveModeViewModel) -> DriveModeCameraPreviewViewController {
        let vc = DriveModeCameraPreviewViewController()
        vc.create(viewModel: viewModel)
        
        return vc
    }
    
    func makeDriveModeSceneFlowCoordinator(navigationController: UINavigationController, parentCoordinator: DriveModeFlowCoordinatorDelegate) -> DriveModeFlowCoordinator {
        DriveModeFlowCoordinator(navigationController: navigationController, dependencies: self, parentDelegate: parentCoordinator)
    }
}
