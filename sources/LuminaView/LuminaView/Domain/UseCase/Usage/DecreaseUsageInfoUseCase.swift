//
//  DecreaseUsageInfoUseCase.swift
//  LuminaView
//
//  Created by 김성준 on 1/11/25.
//

import Foundation

final class DecreaseUsageInfoUseCase {
    let repository: RemoteUsageRepository
    
    init(repository: RemoteUsageRepository) {
        self.repository = repository
    }
    
    func execute(userInfo: UserInfo, decreaseUsageSeconds: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        repository.decreaseUsage(userInfo: userInfo, decreaseUsageSeconds: decreaseUsageSeconds, completion: completion)
    }
}
