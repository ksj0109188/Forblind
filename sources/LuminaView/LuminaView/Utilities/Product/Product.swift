//
//  Product.swift
//  LuminaView
//
//  Created by 김성준 on 12/3/24.
//

import Foundation

enum ProductIdentifier {
    enum Consumable: String, CaseIterable {
        case LumaniaView_1day = "LumaniaView_1day"
        case LumaniaView_1H = "LumaniaView_1H"
        case LumaniaView_4H = "LumaniaView_4H"
        case LumaniaView_7Day = "LumaniaView_7Day"
        case LumaniaView_8H = "LumaniaView_8H"
    }
    
    // 모든 상품 ID를 한 번에 가져오는 계산 프로퍼티
    static var allProductIDs: [String] {
        return Consumable.allCases.map { $0.rawValue }
    }
}


