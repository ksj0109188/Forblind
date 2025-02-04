//
//  AppleInAppPurchaseService.swift
//  LuminaView
//
//  Created by 김성준 on 12/20/24.
//

import Foundation
import StoreKit

final class AppleInAppPurchaseService: PaymentService {
    private var updateListenerTask: Task<Void, Error>? = nil
    
    init() {
        self.updateListenerTask = listenForTransactions()
    }
    
    deinit {
        updateListenerTask?.cancel()
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
        //TODO:   변경필요
        let token = convertUIDToUUID(firebaseUID: "hNJNPsWCkecp4qvGBoO7YjrmKBu1")
        
        let result = try await product.purchase(options: [.appAccountToken(token)])
          
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            await transaction.finish()
            
            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            debugPrint("is unverified")

            throw StoreError.failedVerification
        case .verified(let safe):
            debugPrint("is verified")
            return safe
        }
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
  
                    await transaction.finish()
                } catch {
                    debugPrint("Transaction failed verification.")
                }
            }
        }
    }
}

public enum StoreError: Error {
    case failedVerification
}
