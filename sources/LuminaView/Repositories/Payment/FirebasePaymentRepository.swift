//
//  FirebasePaymentRepository.swift
//  LuminaView
//
//  Created by 김성준 on 12/26/24.
//

import Foundation
import Firebase

final class FirebasePaymentRepository: PaymentRepository {
    private let db = Firestore.firestore()
    
    func createPaymentInfo(paymentInfo: PaymentInfo, completion: @escaping (Result<PaymentInfo, Error>) -> Void) {
        let paymentInfoRef = db.collection("Payment").document(paymentInfo.id)
        
        let paymentData: [String: Any] = [
            "ProductID": paymentInfo.productID,
            "UsageSeconds" : paymentInfo.usageSeconds,
        ]
        
        //MARK: 결제 정보 업데이트와 사용량 정보 업데이트 트랜잭션 분리
        paymentInfoRef.setData(paymentData, merge: true) { error in
            if let error = error {
                debugPrint("Failed to update payment info: \(error.localizedDescription)")
                completion(.failure(PaymentRepositoryErrors.failedUpdatePaymentInfo))
            } else {
                debugPrint("Success create Payment Info")
                let userInfo = UserInfo(id: paymentInfo.userUID,
                                        payments: [paymentInfo.id],
                                        remainUsageSeconds: paymentInfo.usageSeconds)
                completion(.success(paymentInfo))
            }
        }
    }
    
    
    enum PaymentRepositoryErrors: Error {
        case failedUpdatePaymentInfo
    }
}
