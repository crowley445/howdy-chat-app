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
        cameraIconView.isHidden = groupImageView.image != nil
    }

    @IBAction func backButtonTapped (_ sender: Any) {
        addContactsVC.participants = participants
        addContactsVC.filterUsersAndReloadTableView()
        dismissDetail()
    }

    @IBAction func createButtonTapped (_ sender: Any) {
        
        guard let title = titleTextField.text, titleTextField.text != "",
                    let currentId = Auth.auth().currentUser?.uid,
                        participants.count > 0
                            else { return }
        
        present(activityScreen, animated: false, completion: nil)
        
        var ids = participants.map{ $0.uid }
        ids.append(currentId)
        
        if groupImageView.image != nil {
            StorageService.instance.uploadImageToStorage(withImage: groupImageView.image!, andFolderKey: SK_GROUP_IMG, completion: { (imageUrl) in
                DatabaseService.instance.createGroup(withTitle: title, Description: "", andImageUrl: imageUrl, forUserIds: ids, completion: { (success) in
                    self.activityScreen.animateOut(completion: { _ in
                        if success {
                            self.performSegue(withIdentifier: UNWIND_TO_GROUPS, sender: nil)
                        }
                        
                    })
                })
            })
        } else {
            DatabaseService.instance.getUser(withUID: (Auth.auth().currentUser?.uid)!, completion: { (user) in
                DatabaseService.instance.createGroup(withTitle: title, Description: " ", andImageUrl: user.imageURL, forUserIds: ids, completion: { (success) in
                    self.activityScreen.animateOut(completion: { _ in
                        if success {
                            self.performSegue(withIdentifier: UNWIND_TO_GROUPS, sender: nil)
                        }
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
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            self.presentImagePicker(source: UIImagePickerControllerSourceType.photoLibrary)
        } else {
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
        groupImageView.image = selectedImageFromPicker(info: info)
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




