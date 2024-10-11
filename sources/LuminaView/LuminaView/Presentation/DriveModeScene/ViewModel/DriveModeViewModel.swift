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
    var isRecording: PublishSubject<Bool>
    let useCase: FetchGuideUseCase
    let cameraManager: Recodable
    private let actions: DriveModeViewModelActions
    
    init(useCase: FetchGuideUseCase, cameraManager: Recodable, actions: DriveModeViewModelActions) {
        self.useCase = useCase
        self.cameraManager = cameraManager
        self.actions = actions
        self.isRecording = PublishSubject()
    }
    
    func startRecord() {
        let stream = useCase.setupApiConnect()
        cameraManager.startRecord(subject: stream)
    }
    
    func stopRecord() {
        cameraManager.stopRecord()
    }
    
    func setCameraPreview(view: UIView) {
        cameraManager.setPreview(view: view)
    }
    
    func getCameraStatusStream() -> PublishSubject<Bool> {
        return cameraManager.getCameraStatusStream()
    }
    
    func showCameraPreview() {
        actions.showCameraPreview(self)
    }
    
    func stopCameraPreview() {
        actions.dismissCameraPreview()
    }
    
}
