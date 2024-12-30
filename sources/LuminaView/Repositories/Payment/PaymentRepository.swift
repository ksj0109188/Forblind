//
//  PaymentRepository.swift
//  LuminaView
//
//  Created by 김성준 on 12/26/24.
//

import Foundation

protocol PaymentRepository {
    func createPaymentInfo(paymentInfo: PaymentInfo,  completion: @escaping (Result<PaymentInfo, Error>) -> Void)
}
