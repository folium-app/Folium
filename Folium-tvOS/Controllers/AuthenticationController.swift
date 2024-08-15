//
//  AuthenticationController.swift
//  Folium-tvOS
//
//  Created by Jarrod Norwell on 2/7/2024.
//

import AuthenticationServices
import Firebase
import Foundation
import UIKit

extension AuthDataResult : @unchecked @retroactive Sendable {}

class AuthenticationController : UIViewController {
    fileprivate var currentNonce: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        beginAuthenticationFlow()
    }
    
    fileprivate func beginAuthenticationFlow() {
        let nonce: String = .nonce()
        currentNonce = nonce
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]
        request.nonce = .sha256(from: nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}


extension AuthenticationController : ASAuthorizationControllerPresentationContextProviding, @preconcurrency ASAuthorizationControllerDelegate {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let window = view.window {
            window
        } else {
            .init() // MARK: this should not be called
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let currentNonce, let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
        let identityToken = credential.identityToken, let identityTokenString: String = .init(data: identityToken, encoding: .utf8) else {
            return
        }
        
        let appleCredential = OAuthProvider.appleCredential(withIDToken: identityTokenString, rawNonce: currentNonce, fullName: credential.fullName)
        
        let signInTask = Task { try await Auth.auth().signIn(with: appleCredential) }
        Task {
            switch await signInTask.result {
            case .failure(let error):
                print("\(#function): failed: \(error.localizedDescription)")
                
                present(alert(with: "Error", message: error.localizedDescription, preferredStyle: .alert, actions: [
                    .init(title: "Close", style: .cancel)
                ]), animated: true)
            case .success(_):
                print("\(#function): success")
                
                // TODO: add library
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        print("\(#function): failed: \(error.localizedDescription)")
        
        present(alert(with: "Error", message: error.localizedDescription, preferredStyle: .alert, actions: [
            .init(title: "Close", style: .cancel)
        ]), animated: true)
    }
}
