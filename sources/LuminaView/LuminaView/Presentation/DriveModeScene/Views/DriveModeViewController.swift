//
//  DirveModeViewController.swift
//  LuminaView
//
//  Created by 김성준 on 7/9/24.
//

import UIKit
import RxSwift
import RxCocoa
import Lottie

class DriveModeViewController: UIViewController {
    private var viewModel: DriveModeViewModel!
    private var isShowCameraPreview: Bool = false
    private var isRecording: Bool = false
    private lazy var statusLabel: CommonCustomLabel = {
        let label = CommonCustomLabel(label: "Ready To Start", textAlignment: .center, fontSize: 20.0, weight: .bold, textColor: .blue)
        
        return label
    }()
    
    private lazy var progressView: RecognitionProgressView = {
        let view = RecognitionProgressView()
        view.progress(to: 5)
        view.view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var playButton: CommonCustomButton = {
        let button = CommonCustomButton()
        button.set(backgroundColor: .blue, title: "Play", fontSize: 20, weight: .bold, cornerRadius: 16, action: playRecord)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupGesture()
    }
    
    func create(viewModel: DriveModeViewModel) {
        self.viewModel = viewModel
    }
    
    private func setupViews() {
        view.addSubviews(statusLabel, playButton)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let padding = 20.0
//        let frame = view.frame
        
//        NSLayoutConstraint.activate([
//            progressView.view.topAnchor.constraint(equalTo: safeArea.topAnchor),
//            progressView.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
//            progressView.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
//            progressView.view.heightAnchor.constraint(equalToConstant: frame.height / 2)
//            progressView.view.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
//        ])
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: safeArea.topAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor),
            playButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            playButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            playButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
    
    private func setupGesture() {
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2

        // 제스처 인식기를 뷰에 추가
        self.view.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    @objc private func playRecord() {
        debugPrint("Button Tapped")
        if !isRecording {
            viewModel.startRecord()
            isRecording = true
        }
    }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let touchLocation = gesture.location(in: self.view)
        
        if touchLocation.x > self.view.bounds.midX && !isShowCameraPreview {
            viewModel.setCameraPreview(view: view)
            isShowCameraPreview = true
        } else if touchLocation.x < self.view.bounds.midX && isShowCameraPreview {
            viewModel.stopCameraPreview()
            isShowCameraPreview = false
        }
    }
}
