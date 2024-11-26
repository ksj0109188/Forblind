//
//  RegisterUserInfo.swift
//  LuminaView
//
//  Created by 김성준 on 11/20/24.
//

import Foundation

final class RegisterUserInfo {
    let repository: UserInfoRepository
    
    init(repository: UserInfoRepository) {
        self.repository = repository
    }
    
    func execute(uid: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        repository.registerUserInfo(uid: uid, completion: completion)
    }
}
