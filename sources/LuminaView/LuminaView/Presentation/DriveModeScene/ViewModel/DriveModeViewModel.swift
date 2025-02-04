//
//  DriveModeViewModel.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import UIKit
import RxSwift
import CoreMedia

struct DriveModeViewModelActions {
    let showCameraPreview: (_ viewModel: DriveModeViewModel) -> Void
    let showPaymentScene: () -> Void
    let dismissCameraPreview: () -> Void
    let dismiss: (UIViewController) -> Void
    let presetionLoginView: () -> Void
}

final class DriveModeViewModel {
    private var isRecording: PublishSubject<Bool> = PublishSubject()
    private let fetchGuideUseCase: FetchGuideUseCase
    private let stopGuideUseCase: StopGuideUseCase
    private let checkFreeTrialUseCase: CheckFreeTrialUseCase
    private let updateFreeTrialUseCase: UpdateFreeTrialUseCase
    private let fetchUserInfoUseCase: FetchUserInfoUseCase
    private let checkLoginUseCase: CheckLoginUseCase
    private let saveTempUsageUsecase: SaveTempUsageUsecase
    private let decreaseUsageInfoUseCase: DecreaseUsageInfoUseCase
    private let cameraManager: Recodable
    private let speakerManager: Speakable
    private var userInfo: UserInfo?
    private let disposeBag = DisposeBag()
    private let actions: DriveModeViewModelActions
    
    init(fetchGuideUseCase: FetchGuideUseCase,
         stopGuideUseCase: StopGuideUseCase,
         checkFreeTrialUseCase: CheckFreeTrialUseCase,
         updateFreeTrialUseCase: UpdateFreeTrialUseCase,
         fetchUserInfoUseCase: FetchUserInfoUseCase,
         checkLoginUseCase: CheckLoginUseCase,
         saveTempUsageUsecase: SaveTempUsageUsecase,
         decreaseUsageInfoUseCase: DecreaseUsageInfoUseCase,
         cameraManager: Recodable,
         speakerManager: Speakable,
         actions: DriveModeViewModelActions) {
        self.fetchGuideUseCase = fetchGuideUseCase
        self.stopGuideUseCase = stopGuideUseCase
        self.checkFreeTrialUseCase = checkFreeTrialUseCase
        self.updateFreeTrialUseCase = updateFreeTrialUseCase
        self.fetchUserInfoUseCase = fetchUserInfoUseCase
        self.checkLoginUseCase = checkLoginUseCase
        self.saveTempUsageUsecase = saveTempUsageUsecase
        self.decreaseUsageInfoUseCase = decreaseUsageInfoUseCase
        self.cameraManager = cameraManager
        self.speakerManager = speakerManager
        self.actions = actions
    }
    
    private func createResultObserver(stream : PublishSubject<String>) {
        stream
            .subscribe(onNext: { [weak self] content in
                self?.handleContent(content)

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
    
    private func startRecord(requestStream: PublishSubject<CMSampleBuffer>, resultStream: PublishSubject<String>) {
        createResultObserver(stream: resultStream)
        
        fetchGuideUseCase.execute(requestStream: requestStream,
                                  resultStream: resultStream)
        cameraManager.startRecord(subject: requestStream)
        
    }
    
    private func handleContent(_ content: String) {
        speakerManager.speak(content: content)
        
        guard let originUserInfo = userInfo else {
            stopRecordFlow()
            return
        }

        let localUsage = saveTempUsageUsecase.exec()
        
        if originUserInfo.remainUsageSeconds <= localUsage {
            stopRecord()
            updateUsageInfo(originUserInfo, localUsage)
        }
    }
    
    private func handleError(_ error: Error) {
        stopRecordFlow()
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
    
    
    func startRecordFlow() -> PublishSubject<String>  {
        let requestStream = PublishSubject<CMSampleBuffer>()
        let resultStream = PublishSubject<String>()
        
        guard !isFreeTrial() else {
            startRecord(requestStream: requestStream,
                               resultStream: resultStream)
            return resultStream
        }
        
        if let uid = checkLoginUseCase.exec() {
            fetchUserInfoUseCase.execute(uid: uid) {[weak self] result in
                switch result {
                case .success(let userInfo):
                    self?.userInfo = userInfo
                    if userInfo.remainUsageSeconds > 0 {
                        self?.startRecord(requestStream: requestStream, resultStream: resultStream)
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
        
        return resultStream
    }
    
    func stopRecordFlow() {
        stopGuideUseCase.execute()
        stopRecord()
    }
    
    private func stopRecord() {
        cameraManager.stopRecord()
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
    
//    func getResultStream() -> PublishSubject<String>? {
//        return resultStream
//    }
    
}
