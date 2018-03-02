//
//  AuthorisationService.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 07/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import Foundation
import FirebaseCore
import FBSDKLoginKit
import FirebaseAuth
import GoogleSignIn
import TwitterKit

class AuthorisationService {
    static let instance = AuthorisationService()
    
    func facebookAuthorisation (sender: UIViewController ) {
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
    
    func googleAuthorisation () {
        // Google sign in function is found in AppDelegate
        GIDSignIn.sharedInstance().signIn()
    }
    
    func twitterAuthorisation () {
        
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

    func emailAuthorisation (email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("AuthorisationService: Failed to sign in with email. \n\(error)")
                return
            }
            
            print("AuthorisationService: Successfully authorised with Email\n")
            NotificationCenter.default.post(name: NOTIF_FIREBASE_AUTH_SUCCESS, object: nil)
        }
    }

    
    
    func registerNewUser (name: String, email: String, password: String, photoUrl : String) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("AuthorisationService: Failed register new user. \n\(error)")
                NotificationCenter.default.post(name: NOTIF_FIREBASE_AUTH_FAILURE, object: nil)
                return
            }
            
            print("AuthorisationService: Successfully registered new user.\n")

            guard let user = user else {
                print("AuthorisationService: Failed to get user after register new user")
                NotificationCenter.default.post(name: NOTIF_FIREBASE_AUTH_FAILURE, object: nil)
                return
            }
            
            let data = [ DBK_USER_NAME : name, DBK_USER_EMAIL: user.email ?? "", DBK_USER_PROVIDER: user.providerID, DBK_USER_PHOTO_URL: photoUrl] as [String : Any]
            DatabaseService.instance.createDatabaseUser(uid: user.uid, data: data, completion: { (success) in
                if !success {
                    print ("AuthorisationService: Failed to create database user.")
                    NotificationCenter.default.post(name: NOTIF_FIREBASE_AUTH_FAILURE, object: nil)
                    return
                }
                NotificationCenter.default.post(name: NOTIF_FIREBASE_AUTH_SUCCESS, object: nil)
            })
        }
    }
    
    func firebaseAuthorisation(withCredentials credentials: AuthCredential) {
        
        Auth.auth().signIn(with: credentials) { (user, error) in
            if let error = error {
                print("AuthorisationService: Failed final authorisation with Firebase.\n Error: \(error)")
                NotificationCenter.default.post(name: NOTIF_FIREBASE_AUTH_FAILURE, object: nil)
                return
            }
            
            print("AuthorisationService: Successfully authorised with Firebase\n")
            
            guard let user = user else {
                print("AuthorisationService: Failed to get user from Firebase Authorisation.\n")
                NotificationCenter.default.post(name: NOTIF_FIREBASE_AUTH_FAILURE, object: nil)
                return
            }
            
            let data = [ DBK_USER_NAME : user.displayName ?? "", DBK_USER_EMAIL: user.email ?? "", DBK_USER_PROVIDER: credentials.provider, DBK_USER_PHOTO_URL: user.photoURL?.absoluteString ?? ""] as [String : Any]
            DatabaseService.instance.createDatabaseUser(uid: user.uid, data: data, completion: { (success) in
                if !success {
                    print ("AuthorisationService: Failed to create database user.")
                    NotificationCenter.default.post(name: NOTIF_FIREBASE_AUTH_FAILURE, object: nil)
                    return
                }
                NotificationCenter.default.post(name: NOTIF_FIREBASE_AUTH_SUCCESS, object: nil)
            })
        }
    }
}

