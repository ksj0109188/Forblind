//
//  PaymentViewModel.swift
//  LuminaView
//
//  Created by 김성준 on 12/3/24.
//

import RxSwift
import StoreKit
import RxRelay

typealias Transaction = StoreKit.Transaction

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
                    self.productsRelay.accept(fetchedProducts.sorted { $0.price < $1.price})
                }
            } catch {
                print("Error loading products: \(error)")
            }
        }
    }
    
    func purchase(product: Product) async throws -> Transaction? {
    
        let token = UUID(uuidString: "hNJNPsWCkecp4qvGBoO7YjrmKBu1")!
        let result = try await product.purchase(options: [.appAccountToken(token)])
        
        switch result {
        case .success(let verification):
            // Check whether the transaction is verified. If it isn't,
            // this function rethrows the verification error.
            let transaction = try checkVerified(verification)

            // The transaction is verified. Deliver content to the user.
//            await updateCustomerProductStatus()

            // Always finish a transaction.
            await transaction.finish()
            print("purchase result is succed")
            return transaction
        case .userCancelled, .pending:
            print("purchase result is pending and Canceeled")
            return nil
        default:
            return nil
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            print("is unverified")
            // StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            debugPrint("is verified")
            // The result is verified. Return the unwrapped value.
            return safe
        }
    }
    
}

public enum StoreError: Error {
    case failedVerification
}
