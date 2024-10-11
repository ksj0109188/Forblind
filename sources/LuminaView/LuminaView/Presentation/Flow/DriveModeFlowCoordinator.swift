//
//  PlaySongFlowCoordinatorDependencies.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import UIKit

protocol DriveModeFlowCoordinatorDependencies {
    func makeDriveModeViewController(actions: DriveModeViewModelActions) -> DriveModeViewController
    func makeCameraPreviewViewController(viewModel: DriveModeViewModel) -> DriveModeCameraPreviewViewController
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
        let actions = DriveModeViewModelActions(showCameraPreview: showCameraPreview, dismissCameraPreview: dismissCameraPreviewScene)
        let vc = dependencies.makeDriveModeViewController(actions: actions)
        
        navigationController?.pushViewController(vc, animated: false)
    }
    
    private func showCameraPreview(viewModel: DriveModeViewModel) {
        let vc = dependencies.makeCameraPreviewViewController(viewModel: viewModel)
        
        navigationController?.present(vc, animated: false)
    }
    
    private func dismissCameraPreviewScene() {
        navigationController?.dismiss(animated: false)
    }

}
