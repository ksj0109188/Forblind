//
//  PurchaseService.swift
//  LuminaView
//
//  Created by 김성준 on 12/20/24.
//

import Foundation
import StoreKit

protocol PaymentService {
    func purchase(product: Product) async throws -> Transaction?
}
