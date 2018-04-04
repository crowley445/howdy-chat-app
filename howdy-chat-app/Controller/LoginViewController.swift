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
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoImageView: UIImageView!

    var capturedHeight: CGFloat!
    var activityScreen =  ActivityViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signOut()
        
        NotificationCenter.default.addObserver(self, selector: #selector(authSuccess(_:)), name: NOTIF_FIREBASE_AUTH_SUCCESS, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authFailure(_:)), name: NOTIF_FIREBASE_AUTH_FAILURE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gestureToDismissKeyboard(sender:))))
        
        capturedHeight = heightConstraint.constant
        activityScreen.modalPresentationStyle = .overFullScreen
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @objc func keyboardWillShow(_ notif: Notification) {
        
        let keyboardHeight = (notif.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
        let viewHeight = emailTextField.superview?.superview?.superview?.bounds.height
        let constant = (UIScreen.main.bounds.height - keyboardHeight! - viewHeight!) / 4
        let duration = notif.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        handleKeyboardShow(constraint: heightConstraint, constant: constant, duration: duration, _view: view)
    }
    
    @objc func keyboardWillHide(_ notif: Notification) {
        let duration = notif.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        handleKeyboardHide(constraint: heightConstraint, constant: capturedHeight, duration: duration, _view: view)
    }
    
    func handleKeyboardShow( constraint: NSLayoutConstraint, constant: CGFloat, duration: Double, _view: UIView) {

        constraint.constant = constant
 
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25, animations: {
                constraint.firstItem?.subviews.forEach({$0.alpha = 0})
            })
            UIView.addKeyframe(withRelativeStartTime: 0.15, relativeDuration: 0.75, animations: {
                _view.layoutIfNeeded()
            })
        }, completion: nil)
    
    }
    
    func handleKeyboardHide( constraint: NSLayoutConstraint, constant: CGFloat, duration: Double, _view: UIView) {
        
        constraint.constant = constant
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.75, animations: {
                _view.layoutIfNeeded()
            })
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25, animations: {
                constraint.firstItem?.subviews.forEach({$0.alpha = 1})
            })
        }, completion: nil)
    }
    
    @objc func authSuccess (_ notif: NSNotification) {
        activityScreen.animateOut {_ in
            self.performSegue(withIdentifier: UNWIND_TO_GROUPS, sender: nil)
        }
    }
    
    @objc func authFailure (_ notif: NSNotification) {
        activityScreen.animateOut { _ in
            guard let message = notif.userInfo!["message"] as? String else { return }
            self.present(errorAlert(title: "Authorization Failed", message: message), animated: true, completion: nil)
        }
    }
    
    @objc func gestureToDismissKeyboard( sender: UIGestureRecognizer ) {
        view.endEditing(true)
    }
    
    @IBAction func loginButtonTapped (_ sender: Any ) {
        print("AuthorisationVC: Login button tapped. \n")

        guard let email = emailTextField.text, emailTextField.text != "", let password = passwordTextField.text, passwordTextField.text != "" else {
                return
        }
        
        view.endEditing(true)

        present(activityScreen, animated: false, completion: nil)
        AuthorisationService.instance.emailAuthorisation(email: email, password: password)
    }
    
    @IBAction func facebookButtonTapped (_ sender: Any ) {
        AuthorisationService.instance.facebookAuthorisation(sender: self)
    }
    
    @IBAction func twitterButtonTapped (_ sender: Any ) {
        AuthorisationService.instance.twitterAuthorisation()
    }
    
    @IBAction func googleButtonTapped (_ sender: Any ) {
        AuthorisationService.instance.googleAuthorisation()
    }
    
    @IBAction func createAccountButtonTapped (_ sender: Any ) {
        guard let registerUser = storyboard?.instantiateViewController(withIdentifier: SBID_REGISTER_USER) as? RegisterUserViewController
            else { return }
        presentDetail(registerUser)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
