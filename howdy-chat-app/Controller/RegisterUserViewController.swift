//
//  RegisterUserViewController.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 08/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

class RegisterUserViewController: UIViewController {
    
    @IBAction func closeButtonTapped ( _ sender: Any ) {
        print("RegisterUserViewController: Close button tapped. \n")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonTapped ( _ sender: Any ) {
        print("RegisterUserViewController: Register button tapped. \n")
    }
    
    @IBAction func termsAgreementButtonTapped ( _ sender: Any ) {
        print("RegisterUserViewController: Terms Agreement button tapped. \n")
    }
    
}
