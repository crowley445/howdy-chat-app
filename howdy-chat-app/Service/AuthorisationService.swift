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
                self.handleErrorNotification(name: NOTIF_FIREBASE_AUTH_FAILURE, message: error.localizedDescription)
                return
            }
            
            guard let current = FBSDKAccessToken.current(), let token = current.tokenString else {
                self.handleErrorNotification(name: NOTIF_FIREBASE_AUTH_FAILURE, message: nil)
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
                self.handleErrorNotification(name: NOTIF_FIREBASE_AUTH_FAILURE, message: error.localizedDescription)
                return
            }
            
            guard let token = session?.authToken, let secret = session?.authTokenSecret else {
                self.handleErrorNotification(name: NOTIF_FIREBASE_AUTH_FAILURE, message: nil)
                return
            }
            
            self.firebaseAuthorisation(withCredentials: TwitterAuthProvider.credential(withToken: token, secret: secret))
        }
    }

    func emailAuthorisation (email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.handleErrorNotification(name: NOTIF_FIREBASE_AUTH_FAILURE, message: error.localizedDescription)
                return
            }
            
            NotificationCenter.default.post(name: NOTIF_FIREBASE_AUTH_SUCCESS, object: nil)
        }
    }

    func registerNewUser (name: String, email: String, password: String, photoUrl : String) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.handleErrorNotification(name: NOTIF_FIREBASE_REGISTER_FAILURE, message: error.localizedDescription)
                return
            }
            
            guard let user = user else {
                self.handleErrorNotification(name: NOTIF_FIREBASE_REGISTER_FAILURE, message: nil)
                return
            }
            
            let data = [ DBK_USER_NAME : name, DBK_USER_EMAIL: user.email ?? "", DBK_USER_PROVIDER: user.providerID, DBK_USER_PHOTO_URL: photoUrl] as [String : Any]
            DatabaseService.instance.createDatabaseUser(uid: user.uid, data: data, completion: { (success) in
                if !success {
                    self.handleErrorNotification(name: NOTIF_FIREBASE_REGISTER_FAILURE, message: nil)
                    return
                }
                NotificationCenter.default.post(name: NOTIF_FIREBASE_REGISTER_SUCCESS, object: nil)
            })
        }
    }
    
    func firebaseAuthorisation(withCredentials credentials: AuthCredential) {

        Auth.auth().signIn(with: credentials) { (user, error) in
            if let error = error {
                self.handleErrorNotification(name: NOTIF_FIREBASE_AUTH_FAILURE, message: error.localizedDescription)
                return
            }
            
            
            guard let user = user else {
                self.handleErrorNotification(name: NOTIF_FIREBASE_AUTH_FAILURE, message: nil)
                return
            }
            
            let data = [ DBK_USER_NAME : user.displayName ?? "", DBK_USER_EMAIL: user.email ?? "", DBK_USER_PROVIDER: credentials.provider, DBK_USER_PHOTO_URL: user.photoURL?.absoluteString ?? ""] as [String : Any]
            DatabaseService.instance.createDatabaseUser(uid: user.uid, data: data, completion: { (success) in
                if !success {
                    self.handleErrorNotification(name: NOTIF_FIREBASE_AUTH_FAILURE, message: nil)
                    return
                }
                NotificationCenter.default.post(name: NOTIF_FIREBASE_AUTH_SUCCESS, object: nil)
            })
        }
    }
    

    func handleErrorNotification ( name: Notification.Name, message: String?) {
        let _message = message != nil ? message : "Something went wrong during authorization. Please try again."
        NotificationCenter.default.post(name: name, object: nil, userInfo: ["message": _message!  ])
    }
}

