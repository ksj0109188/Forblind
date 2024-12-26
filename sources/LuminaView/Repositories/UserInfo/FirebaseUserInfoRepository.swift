//
//  FirebaseUserInfoRepository.swift
//  LuminaView
//
//  Created by 김성준 on 11/20/24.
//

import Foundation
import Firebase

final class FirebaseUserInfoRepository: UserInfoRepository {
    private let db = Firestore.firestore()
    
    func fetchUserInfo(uid: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        db.collection("User").document(uid).getDocument { (document, error) in
            if let error = error {
                // 에러 발생 시 Completion으로 전달
                completion(.failure(error))
                return
            }
            
            // 문서가 존재하는지 확인
            guard let document = document, document.exists else {
                completion(.failure(NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found"])))
                return
            }
            
            do {
                // do-catch로 Decoding 처리
                let userInfo = try document.data(as: UserInfo.self)
                completion(.success(userInfo))
            } catch {
                completion(.failure(FirebaseError.decodingFailed))
            }
        }
    }
    
    func registerUserInfo(uid: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let userInfo = UserInfo(id: uid, remainUsageSeconds: 0)
        
        do {
            try db.collection("User").document(uid).setData(from: userInfo) { error in
                if let error = error {
                    completion(.failure(error))
                }
                completion(.success(true))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func updateUsage(paymentInfo: PaymentInfo, completion: @escaping (Result<Bool, any Error>) -> Void) {
        let documentRef = db.collection("User").document(paymentInfo.userUID)
           
           // Firestore 업데이트 쿼리
           documentRef.updateData([
            "payments": FieldValue.arrayUnion([paymentInfo.id]), // payments 배열에 새로운 값 추가
            "remainUsageSeconds": FieldValue.increment(Double(paymentInfo.usageSeconds)) // remainUsageSeconds 값 증가
           ]) { error in
               if let error = error {
                   print("Error updating user data: \(error.localizedDescription)")
                   completion(.failure(error))
               } else {
                   print("User data successfully updated!")
                   completion(.success(true))
               }
           }
    }
}

enum FirebaseError: Error {
    case documentNotFound // 문서가 없는 경우
    case decodingFailed   // 데이터 디코딩 실패
    case invalidData      // 데이터 형식이 올바르지 않은 경우
    case networkError     // 네트워크 문제
    case permissionDenied // 권한 부족
    case unknown          // 알 수 없는 에러
}
