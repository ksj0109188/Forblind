//
//  InAppPurchaseUseCase.swift
//  LuminaView
//
//  Created by 김성준 on 12/20/24.
//

import Foundation
import StoreKit

final class InAppPurchaseUseCase {
    let service: PaymentService
    
    init(service: PaymentService) {
        self.service = service
    }
    
    func exec(product: Product) async throws -> Transaction? {
        try await service.purchase(product: product)
    }
}
