//
//  FirebaseUserInfoRepository.swift
//  LuminaView
//
//  Created by 김성준 on 11/20/24.
//

import Foundation
import Firebase

final class FirebaseUserInfoRepository: UserInfoRepository, RemoteUsageRepository {
    private let db = Firestore.firestore()
    
    func fetchUserInfo(uid: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        db.collection("User").document(uid).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.failure(NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found"])))
                return
            }
            
            do {
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
    
    func registerUsage(paymentInfo: PaymentInfo, completion: @escaping (Result<Bool, any Error>) -> Void) {
        let documentRef = db.collection("User").document(paymentInfo.userUID)
           
           documentRef.updateData([
            "payments": FieldValue.arrayUnion([paymentInfo.id]),
            "remainUsageSeconds": FieldValue.increment(Double(paymentInfo.usageSeconds))
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
    
    func decreaseUsage(userInfo: UserInfo, decreaseUsageSeconds: Int, completion: @escaping (Result<Bool, any Error>) -> Void) {
        guard let uid = userInfo.id else {
            completion(.failure(FirebaseError.invalidData))
            return
        }
        
        let documentRef = db.collection("User").document(uid)
        
        documentRef.updateData([
            "remainUsageSeconds": FieldValue.increment(Double(-userInfo.remainUsageSeconds))
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
