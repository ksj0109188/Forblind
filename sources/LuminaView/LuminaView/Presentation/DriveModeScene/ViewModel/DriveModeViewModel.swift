//
//  DriveModeViewModel.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import UIKit
import RxSwift

final class DriveModeViewModel {
    struct DriveModeViewModelActions {
        ///notes: 해당 뷰모델에 속하는 뷰의 동작을 정의
        ///버튼 클릭시 뷰 dismiss및 다른 뷰 표출 등등
        ///flowcoordinaotr에서 이 액션들을 정의
    }
    
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
    
    func stopCameraPreview() {
        cameraManager.stopPreview()
    }
    
}
