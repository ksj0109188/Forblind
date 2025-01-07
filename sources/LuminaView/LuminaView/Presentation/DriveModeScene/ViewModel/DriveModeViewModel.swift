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
    //TODO: 네이밍 다시 생각해보기
    let fetchGuideUseCase: FetchGuideUseCase
    let checkFreeTrialUseCase: CheckFreeTrialUseCase
    let updateFreeTrialUseCase: UpdateFreeTrialUseCase
    let fetchUserInfoUseCase: FetchUserInfoUseCase
    let checkLoginUseCase: CheckLoginUseCase
    let cameraManager: Recodable
    private let disposeBag = DisposeBag()
    private let actions: DriveModeViewModelActions
    private var resultStream: PublishSubject<Result<String, Error>>?
    private var requestStream: PublishSubject<CMSampleBuffer>?
    
    init(fetchGuideUseCase: FetchGuideUseCase, checkFreeTrialUseCase: CheckFreeTrialUseCase, updateFreeTrialUseCase: UpdateFreeTrialUseCase, fetchUserInfoUseCase: FetchUserInfoUseCase, checkLoginUseCase: CheckLoginUseCase, cameraManager: Recodable, actions: DriveModeViewModelActions) {
        self.fetchGuideUseCase = fetchGuideUseCase
        self.checkFreeTrialUseCase = checkFreeTrialUseCase
        self.updateFreeTrialUseCase = updateFreeTrialUseCase
        self.fetchUserInfoUseCase = fetchUserInfoUseCase
        self.checkLoginUseCase = checkLoginUseCase
        self.cameraManager = cameraManager
        self.actions = actions
        
    }
    
    private func createResultOberver() {
        resultStream?
            .subscribe(onNext: { [weak self] result in
            switch result {
            case .success(let content):
                debugPrint("result stream", content)
                //TODO: 별도의 Uitility Manager로 해당 기능을 관리해야함
                let utterance = AVSpeechUtterance(string: content)
                let synthesizer = AVSpeechSynthesizer()
                
                synthesizer.speak(utterance)
            case .failure(let error):
                debugPrint("createResultOberver method", error)
                self?.stopRecord()
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
    
    func startRecordFlow() {
        guard !isFreeTrial() else {
            startRecord()
            return
        }
        
        if let uid = checkLoginUseCase.exec() {
            fetchUserInfoUseCase.execute(uid: uid) {[weak self] result in
                switch result {
                case .success(let userInfo):
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
    
    //MARK: 소캣 연결이 안 됐으면 시작을 하면 안되징
    private func startRecord() {
        requestStream = PublishSubject<CMSampleBuffer>()
        resultStream = PublishSubject<Result<String, Error>>()
        
        createResultOberver()
        
        fetchGuideUseCase.execute(requestStream: requestStream!,
                                  resultStream: resultStream!)
        cameraManager.startRecord(subject: requestStream!)
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
    
    func getResultStream() -> PublishSubject<Result<String, Error>>? {
        return resultStream
    }
    
}
