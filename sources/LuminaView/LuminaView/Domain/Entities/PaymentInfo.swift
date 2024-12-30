//
//  PaymentUpdate.swift
//  LuminaView
//
//  Created by 김성준 on 12/25/24.
//

import Foundation

struct PaymentInfo:Identifiable {
    let id: String
    let productID: String
    let usageSeconds: Int
    let userUID: String
}
