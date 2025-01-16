//
//  UpdateUsageInfoUseCase.swift
//  LuminaView
//
//  Created by 김성준 on 12/25/24.
//

import Foundation

final class RegisterUsageInfoUseCase {
    let repository: RemoteUsageRepository
    
    init(repository: RemoteUsageRepository) {
        self.repository = repository
    }
    
    func execute(paymentInfo: PaymentInfo, completion: @escaping (Result<Bool, Error>) -> Void) {
        repository.registerUsage(paymentInfo: paymentInfo, completion: completion)
    }
}
