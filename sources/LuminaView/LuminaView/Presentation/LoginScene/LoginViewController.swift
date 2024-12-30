//
//  LoginViewController.swift
//  LuminaView
//
//  Created by 김성준 on 10/10/24.
//

import UIKit
import AuthenticationServices
import FirebaseAuth

final class LoginViewController: UIViewController {
    private var viewModel: LoginViewModel!
    
    private var appleLoginButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "LoginButton/appleLogin_button")
        
        button.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    func create(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.addSubviews(appleLoginButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            appleLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleLoginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func signIn() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = viewModel.fetchNonce()
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
       if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
         guard let appleIDToken = appleIDCredential.identityToken else {
           print("Unable to fetch identity token")
           return
         }
         guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
           print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
           return
         }
         // Initialize a Firebase credential, including the user's full name.
         let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: viewModel.fetchNonce(),
                                                           fullName: appleIDCredential.fullName)
         // Sign in with Firebase.
         Auth.auth().signIn(with: credential) { (authResult, error) in
             if (error != nil) {
             // Error. If error.code == .MissingOrInvalidNonce, make sure
             // you're sending the SHA256-hashed nonce as a hex string with
             // your request to Apple.
                 print(error?.localizedDescription)
                 return
           }
           // User is signed in to Firebase with Apple.
           // ...
             print(authResult)
         }
       }
     }

     func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
       // Handle error.
       print("Sign in with Apple errored: \(error)")
     }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.view.window ?? UIWindow()
    }
}

@available(iOS 17, *)
#Preview {
    LoginViewController()
}
