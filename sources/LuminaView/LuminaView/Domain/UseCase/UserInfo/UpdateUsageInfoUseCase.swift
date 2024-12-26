//
//  UpdateUsageInfoUseCase.swift
//  LuminaView
//
//  Created by 김성준 on 12/25/24.
//

import Foundation

final class UpdateUsageInfoUseCase {
    let repository: UserInfoRepository
    
    init(repository: UserInfoRepository) {
        self.repository = repository
    }
    
    func execute(paymentInfo: PaymentInfo, completion: @escaping (Result<Bool, Error>) -> Void) {
        repository.updateUsage(paymentInfo: paymentInfo, completion: completion)
    }
}
