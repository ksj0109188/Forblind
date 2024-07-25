//
//  CameraManger.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import UIKit
import AVFoundation
import RxSwift

protocol Recodable {
    func startRecord(subject: PublishSubject<UIImage>)
    func setPreview(view: UIView)
    func stopPreview()
    func getCameraStatusStream() -> PublishSubject<Bool>
}

final class CameraManger: NSObject, Recodable {
    private var captureSession: AVCaptureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var videoOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    private var cameraDataSubject: PublishSubject<UIImage>!
    private var cameraRecodingCheckSubject: PublishSubject<Bool>!
    private let disposeBag = DisposeBag()
    
    override init() {
        super.init()
        self.configureCamera()
    }
    
    private func configureCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        cameraRecodingCheckSubject = PublishSubject<Bool>()
        cameraRecodingCheckSubject.disposed(by: disposeBag)
        
        // 카메라 장치 가져오기
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            debugPrint("카메라 장치를 찾을 수 없습니다.")
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            } else {
                debugPrint("비디오 입력을 세션에 추가할 수 없습니다.")
                return
            }
        } catch {
            debugPrint("비디오 입력 생성 중 오류 발생: \(error)")
            return
        }
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            debugPrint("비디오 출력을 세션에 추가할 수 없습니다.")
            return
        }
    }
    
    func startRecord(subject: PublishSubject<UIImage>) {
        cameraDataSubject = subject
        
        DispatchQueue.global().async {
            self.captureSession.startRunning()
            self.isRecording()
        }
    }
    
    func setPreview(view: UIView) {
        videoPreviewLayer!.videoGravity = .resizeAspectFill
        videoPreviewLayer!.frame = view.layer.bounds
        
        view.layer.addSublayer(videoPreviewLayer!)
    }
    
    func stopPreview() {
        videoPreviewLayer?.removeFromSuperlayer()
    }
    
    func isRecording()  {
        cameraRecodingCheckSubject.onNext(self.captureSession.isRunning)
    }
    
    func getCameraStatusStream() -> PublishSubject<Bool> {
        self.cameraRecodingCheckSubject
    }
    
}

extension CameraManger: AVCaptureVideoDataOutputSampleBufferDelegate {
    ///note:  AVCaptureVideoDataOutputSampleBufferDelegate 메서드로 출력데이터를 핸들링 할 수 있음
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
            cameraDataSubject?.onNext(uiImage)
        }
    }
}
