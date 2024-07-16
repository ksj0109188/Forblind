//
//  CameraManger.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import UIKit
import AVFoundation

class CameraManger: NSObject {
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var videoOutput: AVCaptureVideoDataOutput!
    
    init(captureSession: AVCaptureSession!, videoPreviewLayer: AVCaptureVideoPreviewLayer!, videoOutput: AVCaptureVideoDataOutput!) {
        self.captureSession = captureSession
        self.videoPreviewLayer = videoPreviewLayer
        self.videoOutput = videoOutput
        
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
}

extension CameraManger: AVCaptureVideoDataOutputSampleBufferDelegate {
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
//            이벤트를 전달할 subject 필요
//            imageSubject.onNext(uiImage)
        }
        
    }
}
