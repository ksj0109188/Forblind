//
//  ViewController.swift
//  LuminaView
//
//  Created by 김성준 on 7/9/24.
//

import UIKit
import AVFoundation
import GoogleGenerativeAI
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var videoOutput: AVCaptureVideoDataOutput!
    let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: "Tempkey")
    let disposeBag = DisposeBag()
    let imageSubject = PublishSubject<UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCamera()
        setupApiConnect()
    }
    
    private func configureCamera() {
        // AVCaptureSession 초기화
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        // 카메라 장치 가져오기
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("카메라 장치를 찾을 수 없습니다.")
            return
        }
        
        // AVCaptureDeviceInput 설정
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                print("비디오 입력을 세션에 추가할 수 없습니다.")
                return
            }
        } catch {
            print("비디오 입력 생성 중 오류 발생: \(error)")
            return
        }
        
        // AVCaptureVideoDataOutput 설정
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            print("비디오 출력을 세션에 추가할 수 없습니다.")
            return
        }

        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
    }
    
    private func setupApiConnect() {
        imageSubject
            .buffer(timeSpan: .seconds(5), count: Int.max, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] images in
                Task {
                    await self?.apiReqeust(images)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func apiReqeust(_ images: [UIImage]) async {
        let prompt = "앞의 사진들을 비교해서 어떤 물체가 다가오고 있는지, 가장 가까운 물체의 거리가 대략 몇m인지 추측해서 알려줘"
        var fullResponse = ""
        
        let contentStream2 = model.generateContentStream(prompt, images.compactMap({ $0}))
        
        do {
            for try await chunk in contentStream2 {
                if let text = chunk.text {
                    fullResponse += text
                }
            }
        } catch(let error) {
            print(error)
        }
        print(fullResponse)
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    // AVCaptureVideoDataOutputSampleBufferDelegate 메서드
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // CVPixelBuffer를 CIImage로 변환
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        // CIImage를 UIImage로 변환
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            imageSubject.onNext(uiImage)
        }
        
    }
}
