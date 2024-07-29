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
    private let disposeBag = DisposeBag()
    private var isRecording: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.updatePlayButtonImage()
                self?.updateStatusLabel()
                self?.updateProgressView()
            }
        }
    }
    
    private lazy var progressView: RecognitionProgressView = {
        let view = RecognitionProgressView()
        view.view.translatesAutoresizingMaskIntoConstraints = false
        view.progressStop()
        
        return view
    }()
    
    private lazy var statusLabel: CommonCustomLabel = {
        let label = CommonCustomLabel(label: "대기중", textAlignment: .center, fontSize: 20.0, weight: .bold, textColor: .white)
        
        return label
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        
        button.addTarget(self, action: #selector(toggleRecordButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(playImage, for: .normal)
        
        return button
    }()
    
    private lazy var playImage: UIImage = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium, scale: .medium)
        let image = UIImage(systemName: "play.fill", withConfiguration: configuration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        return image!
    }()
    
    private lazy var pauseImage: UIImage = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium, scale: .medium)
        let image = UIImage(systemName: "pause.fill", withConfiguration: configuration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        return image!
    }()
    
    private lazy var showCameraPreviewButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 24.0))
        let image = UIImage(systemName: "eye.circle", withConfiguration: configuration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(showCameraPreview), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    func create(viewModel: DriveModeViewModel) {
        self.viewModel = viewModel
        
        viewModel
            .getCameraStatusStream()
            .subscribe { [weak self] in
                self?.isRecording = $0
            }
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        view.addSubviews(statusLabel, playButton, showCameraPreviewButton, progressView.view)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let padding = 20.0
        let frame = view.frame
        
        NSLayoutConstraint.activate([
            progressView.view.topAnchor.constraint(equalTo: safeArea.topAnchor),
            progressView.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            progressView.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            progressView.view.heightAnchor.constraint(equalToConstant: frame.height / 2),
        ])
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: progressView.view.bottomAnchor),
            statusLabel.centerXAnchor.constraint(equalTo: progressView.view.centerXAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: playButton.topAnchor),
        ])
        
        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor),
            playButton.centerXAnchor.constraint(equalTo: statusLabel.centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            showCameraPreviewButton.topAnchor.constraint(equalTo: safeArea.topAnchor),
            showCameraPreviewButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
        ])
    }
    
    private func updatePlayButtonImage() {
        let image = isRecording ? pauseImage : playImage
        
        playButton.setImage(image, for: .normal)
    }
    
    private func updateStatusLabel() {
        if isRecording {
            statusLabel.text = "실행중"
        } else {
            statusLabel.text = "대기중"
        }
    }
    
    private func updateProgressView() {
        if isRecording {
            progressView.progress(to: 0)
        } else {
            progressView.progressStop()
        }
    }
    
    @objc private func toggleRecordButton() {
        if isRecording {
            viewModel.stopRecord()
            isRecording = false
        } else {
            viewModel.startRecord()
            isRecording = true
        }
    }
    
    @objc private func showCameraPreview() {
        print("show camera button tapped")
        viewModel.showCameraPreview()
    }
}
