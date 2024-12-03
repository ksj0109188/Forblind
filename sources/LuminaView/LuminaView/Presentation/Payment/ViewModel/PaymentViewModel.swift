//
//  PaymentViewModel.swift
//  LuminaView
//
//  Created by 김성준 on 12/3/24.
//

import RxSwift
import StoreKit

final class PaymentViewModel {
    
    init() {
        
    }
    
    func fetchProducts() async {
        let products: [String] = ["LumaniaView_1H", "LumaniaView_7day"]
        
        do {
            let products = try await Product.products(for: ProductIdentifier.allProductIDs)
        } catch {
            print("Error for loading on products ")
        }
    }
    
}
