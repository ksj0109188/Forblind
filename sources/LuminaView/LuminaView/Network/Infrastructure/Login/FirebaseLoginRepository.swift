//
//  FirebaseLoginRepository.swift
//  LuminaView
//
//  Created by 김성준 on 11/26/24.
//

import Foundation
import FirebaseAuth

final class FirebaseLoginRepository: LoginRepository {
    let auth = Auth.auth()
    
    func fetchUID() -> String? {
        return auth.currentUser?.uid
    }
}
