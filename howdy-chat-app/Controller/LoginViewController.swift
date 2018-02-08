//
//  LoginViewController.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 08/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func loginButtonTapped (_ sender: Any ) {
        print("AuthorisationVC: Login button tapped. \n")
    }
    
    @IBAction func facebookButtonTapped (_ sender: Any ) {
        print("AuthorisationVC: Facebook button tapped. \n")

    }
    
    @IBAction func twitterButtonTapped (_ sender: Any ) {
        print("AuthorisationVC: Twitter button tapped. \n")
    }
    
    @IBAction func googleButtonTapped (_ sender: Any ) {
        print("AuthorisationVC: Google button tapped. \n")
    }
    
    @IBAction func createAccountButtonTapped (_ sender: Any ) {
        print("AuthorisationVC: Create account button tapped. \n")
        performSegue(withIdentifier: TO_REGISTER_USER, sender: nil)
    }

}
