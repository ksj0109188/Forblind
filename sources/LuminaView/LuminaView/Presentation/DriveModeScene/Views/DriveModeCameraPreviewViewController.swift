//
//  DriveModeCameraPreviewViewController.swift
//  LuminaView
//
//  Created by 김성준 on 7/23/24.
//

import UIKit

final class DriveModeCameraPreviewViewController: UIViewController {
    private var viewModel: DriveModeViewModel!
    
    private lazy var cameraView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .blue
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 24.0))
        let image = UIImage(systemName: "xmark", withConfiguration: configuration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(dismissCameraPreview), for: .touchUpInside)
        
        return button
    }()
    
    func create(viewModel: DriveModeViewModel) {
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.setCameraPreview(view: cameraView)
    }
    
    private func setupViews() {
//        view.addSubviews(cameraView, dismissButton)
        view.addSubviews(dismissButton, cameraView)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let padding = 20.0
            
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: dismissButton.bottomAnchor),
            cameraView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            cameraView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: safeArea.topAnchor),
            dismissButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
        ])
    }
    
    @objc private func dismissCameraPreview() {
        viewModel.stopCameraPreview()
    }
}
