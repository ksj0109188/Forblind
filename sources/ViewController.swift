//
//  ViewController.swift
//  LuminaView
//
//  Created by 김성준 on 7/9/24.
//

import UIKit
import AVFoundation
import GoogleGenerativeAI

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var videoOutput: AVCaptureVideoDataOutput!
    // APIKey는 https://aistudio.google.com/app/apikey 에서 발급 받아주세요!
    let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: "AIzaSyDrUGLBXiCaEYT_3GYk8yU0zAQcS2klkd4")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // AVCaptureSession 초기화
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
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
        
        // 비디오 프리뷰 레이어 설정
        //        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //        videoPreviewLayer.videoGravity = .resizeAspectFill
        //        videoPreviewLayer.frame = view.layer.bounds
        //        view.layer.addSublayer(videoPreviewLayer)
        
        // 세션 시작
        captureSession.startRunning()
    }
    
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
            // UIImage로 변환된 결과를 여기서 사용할 수 있습니다.
            Task {
                await apiReqeust(image: uiImage)
            }
        }
        
        // 여기서 동영상 데이터를 처리합니다.
        
    }
    
    func apiReqeust(image: UIImage) async {
        let prompt = "앞의 사진들을 비교해서 어떤 물체가 다가오고 있는지, 가장 가까운 물체의 거리가 대략 몇m인지 추측해서 알려줘"
        var fullResponse = ""
        let contentStream = model.generateContentStream(prompt, image)
        do {
            for try await chunk in contentStream {
                if let text = chunk.text {
//                    print(text)
                    fullResponse += text
                }
            }
        } catch(let error) {
//            print(error)
        }
        
        print(fullResponse)
    }

    
}
