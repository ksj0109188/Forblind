//
//  DriveModeViewModel.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import Foundation

final class DriveModeViewModel {
    struct DriveModeViewModelActions {
        ///notes: 해당 뷰모델에 속하는 뷰의 동작을 정의
        ///버튼 클릭시 뷰 dismiss및 다른 뷰 표출 등등
    }
    
    let cameraManager: CameraManger
    private let actions: DriveModeViewModelActions
    
    init(cameraManager: CameraManger, actions: DriveModeViewModelActions) {
        self.cameraManager = cameraManager
        self.actions = actions
    }
}
