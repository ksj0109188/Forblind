//
//  LoginViewModel.swift
//  LuminaView
//
//  Created by 김성준 on 10/10/24.
//

import UIKit
import FirebaseAuth

final class LoginViewModel: ObservableObject {
    private let authManger: AuthManager
    private let nonce: String? = nil
    
    init(authManger: AuthManager) {
        self.authManger = authManger
    }
    
    func fetchNonce() -> String {
        if let nonce = nonce {
            return nonce
        } else {
            return authManger.randomNonceString()
        }
    }
}
