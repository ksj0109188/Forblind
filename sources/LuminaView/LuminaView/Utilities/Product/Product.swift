//
//  Product.swift
//  LuminaView
//
//  Created by 김성준 on 12/3/24.
//

import Foundation

enum Products {
    enum Consumable: String, CaseIterable {
        case LumaniaView_1day = "LumaniaView_1day"
        case LumaniaView_1H = "LumaniaView_1H"
        case LumaniaView_4H = "LumaniaView_4H"
        case LumaniaView_7Day = "LumaniaView_7Day"
        case LumaniaView_8H = "LumaniaView_8H"
        
        // 각 케이스에 대해 특정 정수를 매핑
        var durationInSeconds: Int {
            switch self {
            case .LumaniaView_1H: return 3600
            case .LumaniaView_4H: return 14400
            case .LumaniaView_8H: return 28800
            case .LumaniaView_1day: return 86400
            case .LumaniaView_7Day: return 604800
            }
        }
    }
    
    // 모든 상품 ID를 한 번에 가져오는 계산 프로퍼티
    static var allProductIDs: [String] {
        return Consumable.allCases.map { $0.rawValue }
    }
      
    // 특정 문자열로 duration 값을 반환하는 함수
    static func duration(for productID: String) -> Int? {
        return Consumable(rawValue: productID)?.durationInSeconds
    }
}
