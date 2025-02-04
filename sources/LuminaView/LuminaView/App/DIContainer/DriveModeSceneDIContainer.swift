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
        let loginRepository: LoginRepository
        let localUsageRepository: LocalUsageRepository
        let remoteUsageRepository: RemoteUsageRepository
        let cameraManager: Recodable
        let speakManager: Speakable
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: Utilites
    func makeCameraManager() -> Recodable {
        return dependencies.cameraManager
    }
    
    func makeSpeakManager() -> Speakable {
        return dependencies.speakManager
    }
    
    // MARK: UseCase
    func makeDriveModeUsecase() -> FetchGuideUseCase {
        FetchGuideUseCase(guideAPIWebRepository: dependencies.guideAPIWebRepository)
    }
    
    func makeStopDriveModeUsecase() -> StopGuideUseCase {
        StopGuideUseCase(repository: dependencies.guideAPIWebRepository)
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
    
    func makeCheckLoginUseCase() -> CheckLoginUseCase {
        CheckLoginUseCase(repository: dependencies.loginRepository)
    }
    
    func makeSaveTempUsageUsecase() -> SaveTempUsageUsecase {
        SaveTempUsageUsecase(repository: dependencies.localUsageRepository)
    }
    
    func makeDecreaseUsageInfoUseCase() -> DecreaseUsageInfoUseCase {
        DecreaseUsageInfoUseCase(repository: dependencies.remoteUsageRepository)
    }
    
    // MARK: ViewModel
    func makeDriveModeViewModel(actions: DriveModeViewModelActions) -> DriveModeViewModel {
        let viewModel = DriveModeViewModel(fetchGuideUseCase: makeDriveModeUsecase(),
                                           stopGuideUseCase: makeStopDriveModeUsecase(),
                                           checkFreeTrialUseCase: makeCheckFreeTrialUsecase(),
                                           updateFreeTrialUseCase: makeUpdateFreeTrialUsecase(),
                                           fetchUserInfoUseCase: makefetchUserInfoUseCase(),
                                           checkLoginUseCase: makeCheckLoginUseCase(),
                                           saveTempUsageUsecase: makeSaveTempUsageUsecase(),
                                           decreaseUsageInfoUseCase: makeDecreaseUsageInfoUseCase(),
                                           cameraManager: makeCameraManager(), speakerManager: makeSpeakManager(),
                                           actions: actions)
            
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
