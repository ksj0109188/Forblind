//
//  DriveModeViewModel.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import UIKit
import RxSwift

struct DriveModeViewModelActions {
    let showCameraPreview: (_ viewModel: DriveModeViewModel) -> Void
    let dismissCameraPreview: () -> Void
}

final class DriveModeViewModel {
    var subject: PublishSubject<UIImage>?
    let useCase: FetchGuideUseCase
    let cameraManager: Recodable
    private let actions: DriveModeViewModelActions
    
    init(useCase: FetchGuideUseCase, cameraManager: Recodable, actions: DriveModeViewModelActions) {
        self.useCase = useCase
        self.cameraManager = cameraManager
        self.actions = actions
    }
    
    func startRecord() {
        let stream = useCase.setupApiConnect()
        cameraManager.startRecord(stream: stream)
    }
    
    func setCameraPreview(view: UIView) {
        cameraManager.setPreview(view: view)
    }
    
    func showCameraPreview() {
        actions.showCameraPreview(self)
    }
    
    func stopCameraPreview() {
        cameraManager.stopPreview()
    }
    
}
