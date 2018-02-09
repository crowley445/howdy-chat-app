//
//  LoginViewController.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 08/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var emailTextField : UITextField!
    @IBOutlet weak var passwordTextField : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signOut()
    }
    
    @IBAction func loginButtonTapped (_ sender: Any ) {
        print("AuthorisationVC: Login button tapped. \n")
        
        guard let email = emailTextField.text, emailTextField.text != "", let password = passwordTextField.text, passwordTextField.text != "" else {
                return
        }
        AuthorisationService.instance.emailAuthorisation(email: email, password: password)
    }
    
    @IBAction func facebookButtonTapped (_ sender: Any ) {
        print("AuthorisationVC: Facebook button tapped. \n")
        AuthorisationService.instance.facebookAuthorisation(sender: self)
    }
    
    @IBAction func twitterButtonTapped (_ sender: Any ) {
        print("AuthorisationVC: Twitter button tapped. \n")
        AuthorisationService.instance.twitterAuthorisation()
    }
    
    @IBAction func googleButtonTapped (_ sender: Any ) {
        print("AuthorisationVC: Google button tapped. \n")
        AuthorisationService.instance.googleAuthorisation()
    }
    
    @IBAction func createAccountButtonTapped (_ sender: Any ) {
        print("AuthorisationVC: Create account button tapped. \n")
        performSegue(withIdentifier: TO_REGISTER_USER, sender: nil)
    }
}
