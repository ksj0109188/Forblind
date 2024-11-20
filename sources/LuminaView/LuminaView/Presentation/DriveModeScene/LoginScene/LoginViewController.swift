//
//  LoginViewController.swift
//  LuminaView
//
//  Created by 김성준 on 10/10/24.
//

import UIKit

final class LoginViewController: UIViewController {
    private var viewModel: LoginViewModel = LoginViewModel()
    private var appleLoginButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "LoginButton/appleLogin_button")
        
        button.addTarget(self, action: #selector(signIn), for: .touchUpInside)
//        button.target(forAction: #selector(signIn), withSender: nil)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.configure(controller: self)
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.addSubviews(appleLoginButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            appleLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleLoginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func signIn() {
        viewModel.signIn()
    }
    
}

@available(iOS 17, *)
#Preview {
    LoginViewController()
}
