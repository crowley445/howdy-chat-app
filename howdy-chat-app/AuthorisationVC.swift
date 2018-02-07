//
//  AuthorisationVC.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 07/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit
import GoogleSignIn

class AuthorisationVC: UIViewController, GIDSignInUIDelegate {
    
    override func viewDidLoad() {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signOut()
    }
    
    @IBAction func facebookButtonTapped(_sender: Any) {
        print("AuthorisationVC: Facebook button tapped. \n")
        AuthorisationService.instance.facebookAuthorisation(sender: self)
    }
    
    @IBAction func googleButtonTapped(_sender: Any) {
        print("AuthorisationVC: Google button tapped. \n")
        AuthorisationService.instance.googleAuthorisation(sender: self)
    }
    
    @IBAction func twitterButtonTapped(_sender: Any) {
        print("AuthorisationVC: Twitter button tapped. \n")
        AuthorisationService.instance.twitterAuthorisation(sender: self)
    }
    
    @IBAction func emailButtonTapped(_sender: Any) {
        print("AuthorisationVC: Email button tapped. \n")
    }
}

