//
//  LoginViewModel.swift
//  LuminaView
//
//  Created by 김성준 on 10/10/24.
//

import UIKit

final class LoginViewModel: ObservableObject {
    private let authManger: AuthManager = AuthManager()
    
    func configure(controller: UIViewController) {
        authManger.cofigure(controller: controller)
    }
    
    func signIn() {
        authManger.startSignInWithAppleFlow()
    }
    
    
}
