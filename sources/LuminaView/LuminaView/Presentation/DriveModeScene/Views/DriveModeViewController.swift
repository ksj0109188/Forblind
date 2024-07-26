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
    private var isRecording: Bool = false
    private let disposeBag = DisposeBag()
    
    private lazy var statusLabel: CommonCustomLabel = {
        let label = CommonCustomLabel(label: "대기중...", textAlignment: .center, fontSize: 20.0, weight: .bold, textColor: .blue)
        
        return label
    }()
    
    private lazy var progressView: RecognitionProgressView = {
        let view = RecognitionProgressView()
        view.progress(to: 0)
        view.view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var playButton: CommonCustomButton = {
        let button = CommonCustomButton()
        button.set(backgroundColor: .blue, title: "Play", fontSize: 20, weight: .bold, cornerRadius: 16, action: playRecord)
        
        return button
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
                print($0)
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
            statusLabel.centerXAnchor.constraint(equalTo: progressView.view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor),
            playButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            playButton.centerXAnchor.constraint(equalTo: statusLabel.centerXAnchor),
            
        ])
        
        NSLayoutConstraint.activate([
            showCameraPreviewButton.topAnchor.constraint(equalTo: safeArea.topAnchor),
            showCameraPreviewButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
        ])
    }
    
    @objc private func playRecord() {
        if !isRecording {
            viewModel.startRecord()
            isRecording = true
        }
    }
    
    @objc private func showCameraPreview() {
        viewModel.showCameraPreview()
    }
    
}
