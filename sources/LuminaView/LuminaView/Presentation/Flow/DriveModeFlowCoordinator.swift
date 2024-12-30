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

protocol DriveModeFlowCoordinatorDelegate: AnyObject {
    func presentLoginScene()
    func presentPaymentScene()
}

///note DriveMode의 화면 흐름을 정의한다.
final class DriveModeFlowCoordinator: Coordinator {
    var children: [any Coordinator]?
    private weak var navigationController: UINavigationController?
    private weak var delegate: DriveModeFlowCoordinatorDelegate?
    private let dependencies: DriveModeFlowCoordinatorDependencies
    private var onDismissForViewController: [UIViewController: (()->Void)] = [:]
    
    init(navigationController: UINavigationController? = nil,
         dependencies: DriveModeFlowCoordinatorDependencies,
         parentDelegate: DriveModeFlowCoordinatorDelegate?) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.delegate = parentDelegate
    }
    
    func start(animated: Bool, onDismissed: (() -> Void)?) {
        let actions = DriveModeViewModelActions(showCameraPreview: showCameraPreview,
                                                showPaymentScene: presentPaymentView,
                                                dismissCameraPreview: dismissCameraPreviewScene,
                                                dismiss: dismiss,
                                                presetionLoginView: presentLoginView)
        let vc = dependencies.makeDriveModeViewController(actions: actions)
        onDismissForViewController[vc] = onDismissed
        navigationController?.pushViewController(vc, animated: animated)
    }
    
    private func showCameraPreview(viewModel: DriveModeViewModel) {
        let vc = dependencies.makeCameraPreviewViewController(viewModel: viewModel)
        navigationController?.present(vc, animated: false)
    }
    
    private func dismissCameraPreviewScene() {
        navigationController?.dismiss(animated: false)
    }
    
    private func dismiss(for viewController: UIViewController) {
        guard let onDismiss = onDismissForViewController[viewController] else { return }
        onDismiss()
        onDismissForViewController[viewController] = nil
    }
    
    func presentLoginView() {
        delegate?.presentLoginScene()
    }
    
    func presentPaymentView() {
        delegate?.presentPaymentScene()
    }
}
