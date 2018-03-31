//
//  CreateGroupViewController.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 13/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices

class CreateGroupViewController: UIViewController {
    
    @IBOutlet weak var titleTextField : UITextField!
    @IBOutlet weak var participantsView : UICollectionView!
    @IBOutlet weak var countLabel : UILabel!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var cameraIconView: UIImageView!
    @IBOutlet weak var remainingCharacterLabel: UILabel!
    @IBOutlet weak var createButton: UIButton!
    
    var addContactsVC : AddParticipantsViewController!
    var participants = [User]()
    var groupImageSelected = false
    var maxTitleCount = 5
    var activityScreen = ActivityViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        participantsView.delegate = self
        participantsView.dataSource = self
        
        titleTextField.delegate = self
        titleTextField.addTarget(self, action: #selector(titleFieldDidChange), for: UIControlEvents.editingChanged)

        maxTitleCount = Int(remainingCharacterLabel.text!)!
        createButton.isEnabled = false
        activityScreen.modalPresentationStyle = .overFullScreen
        groupImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(groupImageViewTapped)))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gesturedForCloseKeyboard)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        countLabel.text  = "\(participants.count) OF \(addContactsVC.usersArray.count)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(participantsView.frame)
    }
    
    @IBAction func backButtonTapped (_ sender: Any) {
        print("CreateGroupViewController: Back button tapped.\n")
        addContactsVC.participants = participants
        addContactsVC.filterUsersAndReloadTableView()
        dismissDetail()
    }

    @IBAction func createButtonTapped (_ sender: Any) {
        print("CreateGroupViewController: Create group button tapped.\n")
        
        guard let title = titleTextField.text, titleTextField.text != "",
                    let currentId = Auth.auth().currentUser?.uid,
                        participants.count > 0
                            else { return }
        
        present(activityScreen, animated: false, completion: nil)
        
        var ids = participants.map{ $0.uid }
        ids.append(currentId)
        
        if groupImageSelected {
            StorageService.instance.uploadImageToStorage(withImage: groupImageView.image!, andFolderKey: SK_GROUP_IMG, completion: { (imageUrl) in
                DatabaseService.instance.createGroup(withTitle: title, Description: "", andImageUrl: imageUrl, forUserIds: ids, completion: { (success) in
                    
                    self.activityScreen.animateOut(completion: { _ in
                        if !success {
                            print ("CreateGroupViewController: Failed to create new group.\n")
                        }
                        print ("CreateGroupViewController: Successfully created new group.\n")
                        
                        self.performSegue(withIdentifier: UNWIND_TO_GROUPS, sender: nil)
                    })
                })
            })
        } else {
            DatabaseService.instance.getUser(withUID: (Auth.auth().currentUser?.uid)!, completion: { (user) in
                DatabaseService.instance.createGroup(withTitle: title, Description: " ", andImageUrl: user.imageURL, forUserIds: ids, completion: { (success) in
                    
                    self.activityScreen.animateOut(completion: { _ in
                        if !success {
                            print ("CreateGroupViewController: Failed to create new group.\n")
                        }
                        print ("CreateGroupViewController: Successfully created new group.\n")
                        
                        self.performSegue(withIdentifier: UNWIND_TO_GROUPS, sender: nil)
                    })
                })
            })
        }
    }
    
    @objc func gesturedForCloseKeyboard() {
        self.view.endEditing(true)
    }
}
    
extension CreateGroupViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PARTICIPANTS_CELL_ID, for: indexPath) as? ContactCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(withUser: participants[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        participants.remove(at: indexPath.row)
        countLabel.text  = "\(participants.count) OF \(addContactsVC.usersArray.count)"
        participantsView.reloadData()
    }
}

extension CreateGroupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @objc func groupImageViewTapped() {
        let picker = UIImagePickerController()
 
        picker.delegate = self
        picker.allowsEditing = true
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) ? .camera : .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("RegisterUserViewController: Did cancel image picker.")
        groupImageSelected = false
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
            groupImageSelected = true
            cameraIconView.isHidden = true
            groupImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension CreateGroupViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        return newLength <= maxTitleCount
    }

    @objc func titleFieldDidChange () {
        guard let count = self.titleTextField.text?.count else { return }
        self.createButton.isEnabled = count > 0
        remainingCharacterLabel.text = String(maxTitleCount - count)
    }
}











