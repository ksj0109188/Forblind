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
    let showPaymentScene: () -> Void
    let dismissCameraPreview: () -> Void
    let dismiss: (UIViewController) -> Void
    let presetionLoginView: () -> Void
}

final class DriveModeViewModel {
    var isRecording: PublishSubject<Bool> = PublishSubject()
    let fetchGuideUseCase: FetchGuideUseCase
    let checkFreeTrialUseCase: CheckFreeTrialUseCase
    let updateFreeTrialUseCase: UpdateFreeTrialUseCase
    let fetchUserInfoUseCase: FetchUserInfoUseCase
    let checkLoginUseCase: CheckLoginUseCase
    let saveTempUsageUsecase: SaveTempUsageUsecase
    let decreaseUsageInfoUseCase: DecreaseUsageInfoUseCase
    let cameraManager: Recodable
    private var userInfo: UserInfo?
    private let disposeBag = DisposeBag()
    private let actions: DriveModeViewModelActions
    private var resultStream: PublishSubject<String>?
    private var requestStream: PublishSubject<CMSampleBuffer>?
    
    init(fetchGuideUseCase: FetchGuideUseCase,
         checkFreeTrialUseCase: CheckFreeTrialUseCase,
         updateFreeTrialUseCase: UpdateFreeTrialUseCase,
         fetchUserInfoUseCase: FetchUserInfoUseCase,
         checkLoginUseCase: CheckLoginUseCase,
         saveTempUsageUsecase: SaveTempUsageUsecase,
         decreaseUsageInfoUseCase: DecreaseUsageInfoUseCase,
         cameraManager: Recodable,
         actions: DriveModeViewModelActions) {
        self.fetchGuideUseCase = fetchGuideUseCase
        self.checkFreeTrialUseCase = checkFreeTrialUseCase
        self.updateFreeTrialUseCase = updateFreeTrialUseCase
        self.fetchUserInfoUseCase = fetchUserInfoUseCase
        self.checkLoginUseCase = checkLoginUseCase
        self.saveTempUsageUsecase = saveTempUsageUsecase
        self.decreaseUsageInfoUseCase = decreaseUsageInfoUseCase
        self.cameraManager = cameraManager
        self.actions = actions
    }
    
    private func createResultObserver() {
        resultStream?
            .subscribe(onNext: { [weak self] content in
                self?.handleContent(content)
                
                //TODO: 별도의 Uitility Manager로 해당 기능을 관리해야함
                let utterance = AVSpeechUtterance(string: content)
                let synthesizer = AVSpeechSynthesizer()
                
                synthesizer.speak(utterance)
            }, onError: { [weak self] error in
                self?.handleError(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func isFreeTrial() -> Bool {
        return checkFreeTrialUseCase.execute(requestValue: FreeTrialUseCaseRequestValue(entity: .init(remainCount: 10), limitCount: 10))
    }
    
    private func updateFreeTrialCost() {
        updateFreeTrialUseCase.execute(requestValue: FreeTrialUseCaseRequestValue(entity: .init(remainCount: 10), limitCount: 10))
    }
    
    private func startRecord() {
        requestStream = PublishSubject<CMSampleBuffer>()
        resultStream = PublishSubject<String>()
        
        createResultObserver()
        
        fetchGuideUseCase.execute(requestStream: requestStream!,
                                  resultStream: resultStream!)
        cameraManager.startRecord(subject: requestStream!)
    }
    
    private func handleContent(_ content: String) {
        guard let originUserInfo = userInfo else {
            stopRecord()
            return
        }
        
        let localUsage = saveTempUsageUsecase.exec()
        
        if originUserInfo.remainUsageSeconds <= localUsage {
            stopRecord()
            updateUsageInfo(originUserInfo, localUsage)
        }
    }
    
    private func handleError(_ error: Error) {
        stopRecord()
        debugPrint("Error occurred: \(error)")
    }
    
    private func updateUsageInfo(_ userInfo: UserInfo, _ localUsage: Int) {
        decreaseUsageInfoUseCase.execute(userInfo: userInfo, decreaseUsageSeconds: localUsage) { result in
            switch result {
            case .success(let success):
                debugPrint("Usage info updated successfully: \(success)")
            case .failure(let failure):
                debugPrint("Failed to update usage info: \(failure)")
            }
        }
    }
    
    
    func startRecordFlow() {
        guard !isFreeTrial() else {
            startRecord()
            return
        }
        
        if let uid = checkLoginUseCase.exec() {
            fetchUserInfoUseCase.execute(uid: uid) {[weak self] result in
                switch result {
                case .success(let userInfo):
                    self?.userInfo = userInfo
                    if userInfo.remainUsageSeconds > 0 {
                        self?.startRecord()
                    } else {
                        self?.stopRecord()
                        self?.actions.showPaymentScene()
                    }
                case .failure(let failure):
                    debugPrint(failure)
                }
            }
        } else {
            actions.presetionLoginView()
        }
    }
    
    func stopRecord() {
        cameraManager.stopRecord()
        requestStream = nil
        resultStream = nil
    }
    
    func setCameraPreview(view: UIView) {
        cameraManager.setPreview(view: view)
    }
    
    func showCameraPreview() {
        actions.showCameraPreview(self)
    }
    
    func stopCameraPreview() {
        actions.dismissCameraPreview()
    }
    
    func getCameraStatusStream() -> PublishSubject<Bool> {
        return cameraManager.getCameraStatusStream()
    }
    
    func getResultStream() -> PublishSubject<String>? {
        return resultStream
    }
    
}
