//
//  DriveModeViewModel.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import UIKit
import RxSwift
import CoreMedia
import AVFAudio

struct DriveModeViewModelActions {
    let showCameraPreview: (_ viewModel: DriveModeViewModel) -> Void
    let dismissCameraPreview: () -> Void
    let dismiss: (UIViewController) -> Void
    let presetionLoginView: () -> Void
}

final class DriveModeViewModel {
    var isRecording: PublishSubject<Bool>
    //TODO: 네이밍 다시 생각해보기
    let fetchGuideUseCase: FetchGuideUseCase
    let checkFreeTrialUseCase: CheckFreeTrialUseCase
    let updateFreeTrialUseCase: UpdateFreeTrialUseCase
    let fetchUserInfoUseCase: FetchUserInfo
    let cameraManager: Recodable
    private let disposeBag = DisposeBag()
    private let actions: DriveModeViewModelActions
    
    init(isRecording: PublishSubject<Bool>, fetchGuideUseCase: FetchGuideUseCase, checkFreeTrialUseCase: CheckFreeTrialUseCase, updateFreeTrialUseCase: UpdateFreeTrialUseCase, fetchUserInfoUseCase: FetchUserInfo, cameraManager: Recodable, actions: DriveModeViewModelActions) {
        self.isRecording = PublishSubject()
        self.fetchGuideUseCase = fetchGuideUseCase
        self.checkFreeTrialUseCase = checkFreeTrialUseCase
        self.updateFreeTrialUseCase = updateFreeTrialUseCase
        self.fetchUserInfoUseCase = fetchUserInfoUseCase
        self.cameraManager = cameraManager
        self.actions = actions
    }
    
    private func makeObservableResult(stream: PublishSubject<Result<String, Error>>) {
        stream
            .subscribe(onNext: { result in
                switch result {
                    case .success(let content):
                        if !self.isFreeTrial() {
                            self.cameraManager.stopRecord()
                        }
                        
                        //TODO: 별도의 Uitility Manager로 해당 기능을 관리해야함
                        let utterance = AVSpeechUtterance(string: content)
                        let synthesizer = AVSpeechSynthesizer()
                        
                        synthesizer.speak(utterance)
                    case .failure(let error):
                        debugPrint(error)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func isFreeTrial() -> Bool {
        return checkFreeTrialUseCase.execute(requestValue: FreeTrialUseCaseRequestValue(entity: .init(remainCount: 10), limitCount: 10))
    }
    
    private func updateFreeTrialCost() {
        updateFreeTrialUseCase.execute(requestValue: FreeTrialUseCaseRequestValue(entity: .init(remainCount: 10), limitCount: 10))
    }
    
    private func checkUsage() -> Bool {
        guard !isFreeTrial() else { return true }
    
        let sampleUID = "hNJNPsWCkecp4qvGBoO7YjrmKBu1"
        
        fetchUserInfoUseCase.execute(uid: sampleUID) {[weak self] result in
            switch result {
            case .success(let userInfo):
                if userInfo.remainUsageSeconds > 0 {
                    self?.startRecord()
                } else {
                    // checkLoginUser
                    self?.actions.presetionLoginView()
                }
            case .failure(let failure):
                debugPrint(failure)
            }
        }
        
        // 무료 사용량이 남아 있지 않고 로그인이 되어 있는지,
        // 로그인이 되어 있다면 사용량이 0이 아닌지
//        actions.dismiss(viewController)
        return true
    }
    
    func startRecord() {
        // 무료 사용량이 얼마나 남아 있는지
        let requestStream = PublishSubject<CMSampleBuffer>()
        let resultStream = PublishSubject<Result<String, Error>>()
        
        makeObservableResult(stream: resultStream)
        fetchGuideUseCase.execute(requestStream: requestStream, resultStream: resultStream)
        cameraManager.startRecord(subject: requestStream)
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
