//
//  LoginViewModel.swift
//  LuminaView
//
//  Created by 김성준 on 10/10/24.
//

import UIKit
import FirebaseAuth

struct LoginViewModelActions {
    let showDriveModeScene: () -> Void
}

final class LoginViewModel: ObservableObject {
    private let authManger: AuthManager
    private var nonce: String? = nil
    private let actions: LoginViewModelActions
    
    init(authManger: AuthManager, actions: LoginViewModelActions) {
        self.authManger = authManger
        self.actions = actions
    }
    
    func fetchNonce() -> String {
        if let nonce = nonce {
            return nonce
        } else {
            let nonce = authManger.randomNonceString()
            self.nonce = nonce
            
            return nonce
        }
    }
    
    func fetchAppleNonce() -> String {
        let nonce = fetchNonce()
        
        return authManger.sha256(nonce)
    }
    
    func showDriveModeScene() {
        actions.showDriveModeScene()
    }
}
