//
//  DirveModeViewController.swift
//  LuminaView
//
//  Created by 김성준 on 7/9/24.
//

import UIKit
import RxSwift
import RxCocoa

class DriveModeViewController: UIViewController {
    private var viewModel: DriveModeViewModel!
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Ready To Start"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.tintColor = .label
        
        return label
    }()
    
    private lazy var acitivityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    func create(viewModel: DriveModeViewModel) {
        self.viewModel = viewModel
    }
    
    private func setupViews() {
        view.addSubviews(statusLabel, acitivityIndicator)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let padding = 20.0
        let frame = view.frame
        
        NSLayoutConstraint.activate([
            acitivityIndicator.topAnchor.constraint(equalTo: safeArea.topAnchor),
            acitivityIndicator.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            acitivityIndicator.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            acitivityIndicator.heightAnchor.constraint(equalToConstant: frame.height / 2)
        ])
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: acitivityIndicator.bottomAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: padding),
            statusLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: padding),
            statusLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
    
}
