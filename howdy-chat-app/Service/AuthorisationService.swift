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
import TwitterKit

class AuthorisationService {
    static let instance = AuthorisationService()
    
    func facebookAuthorisation (sender: UIViewController) {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: sender) { (result, error) in
            
            if let error = error {
                print ("AuthorisationService: Failed to authorise with Facebook. \n Error: \(error)")
                return
            }
            print("AuthorisationService: Successfully authorised with Facebook\n")

            guard let token = FBSDKAccessToken.current().tokenString else {
                print("AuthorisationService: Failed to get tokens for Facebook credentials.")
                return
            }
            self.firebaseAuthorisation(withCredentials: FacebookAuthProvider.credential(withAccessToken: token) )
        }
    }
    
    func googleAuthorisation (sender: UIViewController) {
        // Google sign in function is found in AppDelegate
        GIDSignIn.sharedInstance().signIn()
    }
    
    func twitterAuthorisation (sender: UIViewController) {
        
        TWTRTwitter.sharedInstance().logIn { (session, error) in
            if let error = error {
                print ("AuthorisationService: Failed to authorise with Twitter. \n Error: \(error)")
                return
            }
            print("AuthorisationService: Successfully authorised with Twitter\n")
            
            guard let token = session?.authToken, let secret = session?.authTokenSecret else {
                print("AuthorisationService: Failed to get tokens for Twitter credentials.")
                return
            }
            
            self.firebaseAuthorisation(withCredentials: TwitterAuthProvider.credential(withToken: token, secret: secret))
        }
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
            
            let data = [ "name" : user.displayName ?? "", "email": user.email ?? "", "provider": credentials.provider, "photoUrl": user.photoURL?.absoluteString ?? ""] as [String : Any]
            DatabaseService.instance.createDatabaseUser(uid: user.uid, data: data)
        }
    }
}

