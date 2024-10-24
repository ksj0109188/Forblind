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
        let updateFreeTrialRepository: FreeTrialRepository
        let cameraManager: Recodable
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: UseCase
    func makeDriveModeUsecase() -> FetchGuideUseCase {
        FetchGuideUseCase(guideAPIWebRepository: dependencies.guideAPIWebRepository)
    }
    
    func makeCheckFreeTrialUsecase() -> CheckFreeTrialUseCase {
        CheckFreeTrialUseCase(repository: dependencies.freeTrialRepository)
    }
    
    func makeCheckFreeTrialUsecase() -> UpdateFreeTrialUseCase {
        UpdateFreeTrialUseCase(repository: dependencies.freeTrialRepository)
    }
    
    // MARK: ViewModel
    func makeDriveModeViewModel(actions: DriveModeViewModelActions) -> DriveModeViewModel {
        let viewModel = DriveModeViewModel(useCase: makeDriveModeUsecase(), freeTrialUsecase: makeCheckFreeTrialUsecase(), updateFreeTrialUseCase: makeCheckFreeTrialUsecase(), cameraManager: dependencies.cameraManager, actions: actions)
        
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
    
    func makeDriveModeSceneFlowCoordinator(navigationController: UINavigationController) -> DriveModeFlowCoordinator {
        DriveModeFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
}
