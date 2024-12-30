//
//  AuthManager.swift
//  LuminaView
//
//  Created by 김성준 on 10/10/24.
//

import Foundation
import CryptoKit
import AuthenticationServices
import FirebaseAuth

final class AuthManager: NSObject {
    private var currentNonce: String?
    private var authController: UIViewController!
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    @available(iOS 13, *)
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }

//    @available(iOS 13, *)
//    func startSignInWithAppleFlow() {
//      let nonce = randomNonceString()
//      currentNonce = nonce
//      let appleIDProvider = ASAuthorizationAppleIDProvider()
//      let request = appleIDProvider.createRequest()
//      request.requestedScopes = [.fullName, .email]
//      request.nonce = sha256(nonce)
//
//      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//      authorizationController.delegate = self
//      authorizationController.presentationContextProvider = self
//      authorizationController.performRequests()
//    }
    
    func fetchUID() -> String? {
        return Auth.auth().currentUser?.uid
    }
}

//extension AuthManager : ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
//    //UIWindow View
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return authController.view.window ?? UIWindow()
//    }
//    
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//       if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//         guard let nonce = currentNonce else {
//           fatalError("Invalid state: A login callback was received, but no login request was sent.")
//         }
//         guard let appleIDToken = appleIDCredential.identityToken else {
//           print("Unable to fetch identity token")
//           return
//         }
//         guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//           print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
//           return
//         }
//         // Initialize a Firebase credential, including the user's full name.
//         let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
//                                                           rawNonce: nonce,
//                                                           fullName: appleIDCredential.fullName)
//         // Sign in with Firebase.
//         Auth.auth().signIn(with: credential) { (authResult, error) in
//             if (error != nil) {
//             // Error. If error.code == .MissingOrInvalidNonce, make sure
//             // you're sending the SHA256-hashed nonce as a hex string with
//             // your request to Apple.
//                 print(error?.localizedDescription)
//             return
//           }
//           // User is signed in to Firebase with Apple.
//           // ...
//         }
//       }
//     }
//
//     func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//       // Handle error.
//       print("Sign in with Apple errored: \(error)")
//     }
//}
