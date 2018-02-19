//
//  CreateGroupViewController.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 13/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit
import Firebase

class CreateGroupViewController: UIViewController {
    
    @IBOutlet weak var titleTextField : UITextField!
    @IBOutlet weak var descriptionTextField : UITextField!
    @IBOutlet weak var participantsView : UICollectionView!
    @IBOutlet weak var countLabel : UILabel!
    @IBOutlet weak var groupImageView: UIImageView!
    
    var addContactsVC : AddParticipantsViewController!
    var participants = [User]()
    var groupImageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        participantsView.delegate = self
        participantsView.dataSource = self
        groupImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(groupImageViewTapped)))
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
                let description = descriptionTextField.text, descriptionTextField.text != "",
                    let currentId = Auth.auth().currentUser?.uid,
                        participants.count > 0
                            else { return }

        var ids = participants.map{ $0.uid }
        ids.append(currentId)
        
        if groupImageSelected {
            StorageService.instance.uploadImageToStorage(withImage: groupImageView.image!, andFolderKey: SK_GROUP_IMG, completion: { (imageUrl) in
                DatabaseService.instance.createGroup(withTitle: title, Description: description, andImageUrl: imageUrl, forUserIds: ids, completion: { (success) in
                    if !success {
                        print ("CreateGroupViewController: Failed to create new group.\n")
                    }
                    print ("CreateGroupViewController: Successfully created new group.\n")
                    self.performSegue(withIdentifier: UNWIND_TO_GROUPS, sender: nil)
                })
            })
        } else {
            DatabaseService.instance.getUser(withUID: (Auth.auth().currentUser?.uid)!, completion: { (user) in
                DatabaseService.instance.createGroup(withTitle: title, Description: description, andImageUrl: user.imageURL, forUserIds: ids, completion: { (success) in
                    if !success {
                        print ("CreateGroupViewController: Failed to create new group.\n")
                    }
                    print ("CreateGroupViewController: Successfully created new group.\n")
                    self.performSegue(withIdentifier: UNWIND_TO_GROUPS, sender: nil)
                })
            })
        }
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
            groupImageSelected = true
            groupImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}
