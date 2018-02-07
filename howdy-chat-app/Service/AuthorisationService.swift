//
//  AuthorisationService.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 07/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AuthorisationService {
    static let instance = AuthorisationService()
    
    func facebookAuthorisation (sender: UIViewController) {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: sender) { (result, error) in
            
            if let error = error {
                print ("AuthorisationService: Failed to authorise with Facebook. \n Error: \(error)")
            }
            print("AuthorisationService: Successfully authorised with Facebook\n")

            guard let token = FBSDKAccessToken.current().tokenString else { return }
            self.firebaseAuthorisation(withCredentials: FacebookAuthProvider.credential(withAccessToken: token) )
        }
    }
    
    func googleAuthorisation (sender: UIViewController) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func firebaseAuthorisation(withCredentials credentials: AuthCredential) {
        Auth.auth().signIn(with: credentials) { (user, error) in
            if let error = error {
                print("AuthorisationService: Failed final authorisation with Firebase.\n Error: \(error)")
            }
            
            print("AuthorisationService: Successfully authorised with Firebase\n")
            
            guard let user = user else {
                print("AuthorisationService: Failed to get user from Firebase Authorisation.\n")
                return
            }
            
            let data = [ "name" : user.displayName ?? "", "email": user.email ?? "", "provider": user.providerID, "photoUrl": user.photoURL?.absoluteString ?? ""] as [String : Any]
            DatabaseService.instance.createDatabaseUser(uid: user.uid, data: data)
        }
    }
}

