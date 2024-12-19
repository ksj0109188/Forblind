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
    private var updateListenerTask: Task<Void, Error>? = nil
    
    var products: Observable<[Product]> {
        return productsRelay.asObservable()
    }
    
    init() {
        self.updateListenerTask = listenForTransactions()
    }
    
    deinit {
        updateListenerTask?.cancel()
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
    
    func convertUIDToUUID(firebaseUID: String) -> UUID {
        // Firebase UID를 해싱하여 UUID 형태로 변환
        let hash = firebaseUID.hashValue
        let uuidString = String(format: "%08X-%04X-%04X-%04X-%012X",
                                (hash >> 96) & 0xFFFFFFFF,
                                (hash >> 80) & 0xFFFF,
                                ((hash >> 64) & 0x0FFF) | 0x4000, // UUID version 4
                                ((hash >> 48) & 0x3FFF) | 0x8000, // UUID variant
                                hash & 0xFFFFFFFFFFFF)
        return UUID(uuidString: uuidString)!
    }
    
    func purchase(product: Product) async throws -> Transaction? {
        
        let token = convertUIDToUUID(firebaseUID: "hNJNPsWCkecp4qvGBoO7YjrmKBu1")
        
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
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    print("Listen For Transactions")
                    // Always finish a transaction.
                    await transaction.finish()
                } catch {
                    // StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    print("Transaction failed verification.")
                }
            }
        }
    }
    
}

public enum StoreError: Error {
    case failedVerification
}
