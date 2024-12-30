//
//  CreatePaymentInfo.swift
//  LuminaView
//
//  Created by 김성준 on 12/25/24.
//

import Foundation

final class CreatePaymentInfoUseCase {
    private let repository: PaymentRepository
    
    init(repository: PaymentRepository) {
        self.repository = repository
    }

    func execute(paymentInfo: PaymentInfo, completion: @escaping (Result<PaymentInfo, Error>) -> Void) {
        repository.createPaymentInfo(paymentInfo: paymentInfo, completion: completion)
     }
}
