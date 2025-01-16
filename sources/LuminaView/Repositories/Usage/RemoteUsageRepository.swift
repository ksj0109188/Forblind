//
//  RemoteUsageRepository.swift
//  LuminaView
//
//  Created by 김성준 on 1/10/25.
//

import Foundation

protocol RemoteUsageRepository {
    func registerUsage(paymentInfo: PaymentInfo, completion: @escaping (Result<Bool, Error>) -> Void)
    func decreaseUsage(userInfo: UserInfo, decreaseUsageSeconds: Int, completion: @escaping (Result<Bool, any Error>) -> Void)
}
