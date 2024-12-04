//
//  PaymentViewModel.swift
//  LuminaView
//
//  Created by 김성준 on 12/3/24.
//

import RxSwift
import StoreKit
import RxRelay

final class PaymentViewModel {
    private let disposeBag = DisposeBag()
    private let productsRelay = BehaviorRelay<[Product]>(value: [])
    
    var products: Observable<[Product]> {
        return productsRelay.asObservable()
    }
    
    func fetchProducts() {
        Task {
            do {
                let fetchedProducts = try await Product.products(for: ProductIdentifier.allProductIDs)
                
                DispatchQueue.main.async {
                    self.productsRelay.accept(fetchedProducts)
                }
            } catch {
                print("Error loading products: \(error)")
            }
        }
    }
    
}
