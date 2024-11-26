//
//  LoginViewModel.swift
//  LuminaView
//
//  Created by 김성준 on 10/10/24.
//

import UIKit
import FirebaseAuth

final class LoginViewModel: ObservableObject {
    private let authManger: AuthManager = AuthManager()
    private let firebae = FirebaseUserInfoRepository()
    
    func configure(controller: UIViewController) {
        authManger.cofigure(controller: controller)
    }
    
//    func signIn() {
//        authManger.startSignInWithAppleFlow()
//    }
    func signIn() {
        
        if let uid = authManger.fetchUid() {
            firebae.fetchUserInfo(uid: uid) { result in
                switch result {
                case .success(let success):
                    print(success)
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }
    
}
