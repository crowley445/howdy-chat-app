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
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageView : UIImageView!
    @IBOutlet weak var cameraIcomImageView : UIImageView!
    
    var capturedHeight: CGFloat!
    var activityScreen =  ActivityViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(registerSuccess), name: NOTIF_FIREBASE_REGISTER_SUCCESS, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(registerFailure), name: NOTIF_FIREBASE_REGISTER_FAILURE, object: nil)
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped)))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gestureToDismissKeyboard)))
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        capturedHeight = heightConstraint.constant
        activityScreen.modalPresentationStyle = .overCurrentContext
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraIcomImageView.isHidden = profileImageView.image != nil
    }

    @objc func keyboardWillShow(_ notif: Notification) {
        guard let LoginVC = presentingViewController as? LoginViewController else { return }
        
        let keyboardHeight = (notif.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
        let viewHeight = emailTextField.superview?.superview?.superview?.bounds.height
        let constant = (UIScreen.main.bounds.height - keyboardHeight! - viewHeight!) / 4
        let duration = notif.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        LoginVC.handleKeyboardShow(constraint: heightConstraint, constant: constant, duration: duration, _view: view)
    }
    
    @objc func keyboardWillHide(_ notif: Notification) {
        guard let LoginVC = presentingViewController as? LoginViewController else { return }

        let duration = notif.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        LoginVC.handleKeyboardHide(constraint: heightConstraint, constant: capturedHeight, duration: duration, _view: view)
    }
    
    @objc func registerSuccess(_ notif: NSNotification) {
        activityScreen.animateOut {_ in
            self.performSegue(withIdentifier: UNWIND_TO_GROUPS, sender: nil)
        }
    }
    
    @objc func registerFailure(_ notif: NSNotification) {
        activityScreen.animateOut { _ in
            guard let message = notif.userInfo!["message"] as? String else { return }
            self.present(errorAlert(title: "Registration Failed", message: message), animated: true, completion: nil)
        }
    }
    
    @objc func gestureToDismissKeyboard( sender: UIGestureRecognizer ) {
        view.endEditing(true)
    }
    
    @IBAction func closeButtonTapped ( _ sender: Any ) {
        dismissDetail()
    }
    
    @IBAction func registerButtonTapped ( _ sender: Any ) {
        
        guard let name = nameTextField.text, nameTextField.text != "",
        let email = emailTextField.text, emailTextField.text != "",
        let password = passwordTextField.text, passwordTextField.text != "" else { return }
        
        view.endEditing(true)
        present(activityScreen, animated: false, completion: nil)
        
        if profileImageView.image != nil
        {
            StorageService.instance.uploadImageToStorage(withImage: profileImageView.image!, andFolderKey: SK_PROFILE_IMG, completion: { (urlString) in
                AuthorisationService.instance.registerNewUser(name: name, email: email, password: password, photoUrl: urlString)
            })
        }
        else
        {
            AuthorisationService.instance.registerNewUser(name: name, email: email, password: password, photoUrl: "")
        }        
    }
}

extension RegisterUserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func profileImageViewTapped() {
        
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        {
            self.presentImagePicker(source: UIImagePickerControllerSourceType.photoLibrary)
        }
        else
        {
            present(imageActionSheet(presentImagePicker: presentImagePicker), animated: true, completion: nil)
        }
        
    }
    
    func presentImagePicker( source: UIImagePickerControllerSourceType) {
        present(getImagePicker(source: source, delegate: self), animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profileImageView.image = selectedImageFromPicker(info: info)
        dismiss(animated: true, completion: nil)
    }
}

extension RegisterUserViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


