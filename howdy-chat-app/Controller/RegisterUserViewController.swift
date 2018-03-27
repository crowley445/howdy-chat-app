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
    @IBOutlet weak var profileImageView : UIImageView!
    
    var profileImageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authSuccess), name: NOTIF_FIREBASE_AUTH_SUCCESS, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authFailure), name: NOTIF_FIREBASE_AUTH_FAILURE, object: nil)
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped)))
    }

    @objc func keyboardWillShow(_ notif: Notification) {
        let duration = notif.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double

        UIView.animate(withDuration: duration) {
            
        }
    }
    
    @objc func keyboardWillHide(_ notif: Notification) {
        let duration = notif.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double

        UIView.animate(withDuration: duration) {
            
        }
    }
    
    @objc func authSuccess() {
        performSegue(withIdentifier: UNWIND_TO_GROUPS, sender: nil)
    }
    
    @objc func authFailure() {
        print("RegisterUserViewController: Authorisation failed!")
    }
    
    @IBAction func closeButtonTapped ( _ sender: Any ) {
        print("RegisterUserViewController: Close button tapped. \n")
        dismissDetail()
    }
    
    @IBAction func registerButtonTapped ( _ sender: Any ) {
        print("RegisterUserViewController: Register button tapped. \n")
        guard let name = nameTextField.text, nameTextField.text != "",
        let email = emailTextField.text, emailTextField.text != "",
        let password = passwordTextField.text, passwordTextField.text != "" else { return }
        
        if profileImageSelected {
            StorageService.instance.uploadImageToStorage(withImage: profileImageView.image!, andFolderKey: SK_PROFILE_IMG, completion: { (urlString) in
                AuthorisationService.instance.registerNewUser(name: name, email: email, password: password, photoUrl: urlString)
            })
        } else {
            AuthorisationService.instance.registerNewUser(name: name, email: email, password: password, photoUrl: "")
        }        
    }
    
    @IBAction func termsAgreementButtonTapped ( _ sender: Any ) {
        print("RegisterUserViewController: Terms Agreement button tapped. \n")
    }
}

extension RegisterUserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @objc func profileImageViewTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("RegisterUserViewController: Did cancel image picker.")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("RegisterUserViewController: Did select image from picker.")
        
        var selectedImageFromPicker : UIImage?
        
        if let editiedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editiedImage
        }
        else if let originalImage = info["UIImagePickerControllerReferenceURL"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageSelected = true
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}


