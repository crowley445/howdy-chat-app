//
//  RegisterUserViewController.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 08/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

class RegisterUserViewController: UIViewController {
    
    @IBOutlet weak var nameTextField : UITextField!
    @IBOutlet weak var emailTextField : UITextField!
    @IBOutlet weak var passwordTextField : UITextField!
    @IBOutlet weak var confirmTextField : UITextField!

    @IBAction func closeButtonTapped ( _ sender: Any ) {
        print("RegisterUserViewController: Close button tapped. \n")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonTapped ( _ sender: Any ) {
        print("RegisterUserViewController: Register button tapped. \n")
        guard let name = nameTextField.text, nameTextField.text != "",
        let email = emailTextField.text, emailTextField.text != "",
        let password = passwordTextField.text, passwordTextField.text != "",
            passwordTextField.text == confirmTextField.text else {
                return
        }
        AuthorisationService.instance.registerNewUser(name: name, email: email, password: password)
    }
    
    @IBAction func termsAgreementButtonTapped ( _ sender: Any ) {
        print("RegisterUserViewController: Terms Agreement button tapped. \n")
    }
    
}
