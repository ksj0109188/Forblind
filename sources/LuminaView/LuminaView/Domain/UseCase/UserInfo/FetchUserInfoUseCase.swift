//
//  FetchUserInfo.swift
//  LuminaView
//
//  Created by 김성준 on 11/20/24.
//

import Foundation

final class FetchUserInfo {
    let repository: UserInfoRepository
    
    init(repository: UserInfoRepository) {
        self.repository = repository
    }
    
    func execute(uid: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        repository.fetchUserInfo(uid: uid, completion: completion)
    }
}
