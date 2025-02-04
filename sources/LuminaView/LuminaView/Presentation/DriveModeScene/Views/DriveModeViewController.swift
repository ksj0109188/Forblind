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
                self?.updatePlayButton()
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
        let label = CommonCustomLabel(label: "Stopped", textAlignment: .center, fontSize: 20.0, weight: .bold, textColor: .white)
        label.isAccessibilityElement = false
        
        return label
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        
        button.addTarget(self, action: #selector(toggleRecordButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(playImage, for: .normal)
        button.accessibilityLabel = String(localized: "PlayGuide")
        
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
        
        button.addTarget(self, action: #selector(showCameraPreview), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        button.accessibilityLabel = String(localized: "showCameraPreview")
        
        return button
    }()
    
    private lazy var showUserInfoButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 24.0))
        let image = UIImage(systemName: "info.circle", withConfiguration: configuration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        button.addTarget(self, action: #selector(showUserInfo), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        button.accessibilityLabel = String(localized: "showUserInfo")
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setVoiceOverAccessConfig()
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
        view.addSubviews(statusLabel, playButton, showCameraPreviewButton, showUserInfoButton, progressView.view)
    }
    
    private func setVoiceOverAccessConfig() {
        view.accessibilityElements = [showCameraPreviewButton, playButton]
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let padding = 20.0
        let frame = view.frame
        
        NSLayoutConstraint.activate([
            progressView.view.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: frame.height / 10),
            progressView.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            progressView.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            progressView.view.heightAnchor.constraint(equalToConstant: frame.height / 2),
        ])
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: progressView.view.bottomAnchor),
            statusLabel.centerXAnchor.constraint(equalTo: progressView.view.centerXAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: playButton.topAnchor),
            statusLabel.heightAnchor.constraint(equalToConstant: view.frame.height / 10)
        ])
        
        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor),
            playButton.centerXAnchor.constraint(equalTo: statusLabel.centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: padding),
        ])
        
        NSLayoutConstraint.activate([
            showCameraPreviewButton.topAnchor.constraint(equalTo: safeArea.topAnchor),
            showCameraPreviewButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            showUserInfoButton.topAnchor.constraint(equalTo: safeArea.topAnchor),
            showUserInfoButton.trailingAnchor.constraint(equalTo: showCameraPreviewButton.leadingAnchor, constant: -padding)
        ])
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error occur",
            message: message,
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: nil)
        alert.addAction(confirmAction)
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func showUserInfoSheet(userInfo: UserInfo) {
        let alert = UIAlertController(title: "User information", message: "remain usage: \(userInfo.remainUsageString)", preferredStyle: .actionSheet)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: nil)
        alert.addAction(confirmAction)
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func updatePlayButton() {
        let image = isRecording ? pauseImage : playImage
        let voiceOverHint = isRecording ? String(localized: "PauseGuide") : String(localized: "PlayGuide")
        
        playButton.accessibilityLabel = voiceOverHint
        playButton.setImage(image, for: .normal)
    }
    
    private func updateStatusLabel() {
        if isRecording {
            statusLabel.text = "Running"
        } else {
            statusLabel.text = "Stopped"
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
            viewModel.startRecordFlow()
                .subscribe(onError: { [weak self] error in
                    debugPrint("viewController resultStream error: \(error)")
                    self?.isRecording = false
                    self?.showErrorAlert(message: error.localizedDescription)
                })
                .disposed(by: disposeBag)
            isRecording = true
        }
    }
    
    @objc private func showCameraPreview() {
        viewModel.showCameraPreview()
    }
    
    @objc private func showUserInfo() {
        viewModel.showUserInfo(completion: showUserInfoSheet)
    }
}
