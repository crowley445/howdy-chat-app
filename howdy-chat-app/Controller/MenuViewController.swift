//
//  MenuViewController.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 16/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
class MenuViewController: UIViewController {
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        print("MenuViewController: Logout button tapped.\n")
        
        do {
            try Auth.auth().signOut()
        } catch {
            print("MenuViewController: Failed to sign out user.\n\(error)")
        }
        
        guard let loginVC = storyboard?.instantiateViewController(withIdentifier: SBID_LOGIN_USER) as? LoginViewController else {
            return
        }
        self.present(loginVC, animated: true, completion: nil)
    }
}
