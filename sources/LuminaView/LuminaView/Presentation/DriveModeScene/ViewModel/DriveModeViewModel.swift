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
}

final class DriveModeViewModel {
    var isRecording: PublishSubject<Bool>
    //TODO: 네이밍 다시 생각해보기
    let fetchGuideUseCase: FetchGuideUseCase
    let checkFreeTrialUsecase: CheckFreeTrialUseCase
    let updateFreeTrialUseCase: UpdateFreeTrialUseCase
    let cameraManager: Recodable
    private let disposeBag = DisposeBag()
    private let actions: DriveModeViewModelActions
    
    init(useCase: FetchGuideUseCase,
         freeTrialUsecase: CheckFreeTrialUseCase,
         updateFreeTrialUseCase: UpdateFreeTrialUseCase,
         cameraManager: Recodable,
         actions: DriveModeViewModelActions) {
        
        self.fetchGuideUseCase = useCase
        self.checkFreeTrialUsecase = freeTrialUsecase
        self.updateFreeTrialUseCase = updateFreeTrialUseCase
        self.cameraManager = cameraManager
        self.actions = actions
        self.isRecording = PublishSubject()
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
    
    // 무료 사용량에 해당하는지
    private func isFreeTrial() -> Bool {
        return checkFreeTrialUsecase.execute(requestValue: FreeTrialUseCaseRequestValue(entity: .init(remainCount: 10), limitCount: 10))
    }
    
    private func updateFreeTrialCost() {
        updateFreeTrialUseCase.execute(requestValue: FreeTrialUseCaseRequestValue(entity: .init(remainCount: 10), limitCount: 10))
    }
    
    func startRecord() {
        // 그렇다면 로그인이 되어 있는지, 로그인 후 사용량이 얼마나 남아 있는지
        if isFreeTrial() {
            let requestStream = PublishSubject<CMSampleBuffer>()
            let resultStream = PublishSubject<Result<String, Error>>()
            
            makeObservableResult(stream: resultStream)
            fetchGuideUseCase.execute(requestStream: requestStream, resultStream: resultStream)
            cameraManager.startRecord(subject: requestStream)
        }
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
