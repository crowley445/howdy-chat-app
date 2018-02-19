//
//  ChatViewController.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 14/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var messageField : UITextField!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var groupTitleLabel: UILabel!
    @IBOutlet weak var inputViewBottomAncor: NSLayoutConstraint!
    @IBOutlet weak var imagePickerButton: UIButton!
    
    var group : Group?
    var members = [String:User]()
    var messages = [Message]()

    override func viewDidLoad() {
        super.viewDidLoad()
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notif:)), name: .UIKeyboardWillChangeFrame, object: nil)
        imagePickerButton.addTarget(self, action: #selector(imageButtonTapped), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupTitleLabel.text = group?.title
        DatabaseService.instance.REF_GROUPS.observe(.value) { (dataSnapShot) in
            DatabaseService.instance.getMessagesFor(desiredGroup: self.group!, completion: { (messages) in
                self.messages = messages
                self.messageTableView.reloadData()
                self.scrollToEnd()
            })
        }
    }
    
    @objc func keyboardWillChange( notif: NSNotification) {
        self.inputViewBottomAncor.constant = -(notif.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        let duration = notif.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
            self.scrollToEnd()
        }
    }
    
    @IBAction func backButtonTapped (_ sender: Any) {
        print("ChatViewController: Back button tapped.\n")
        dismissDetail()
    }
    
    @IBAction func sendButtonTapped (_ sender: Any) {
        print("ChatViewController: Send button tapped.\n")
        guard let content = messageField.text, messageField.text != "" else { return }
        let message = Message(senderId: (Auth.auth().currentUser?.uid)!, content: content, imageUrl: "")
        DatabaseService.instance.uploadPost(withMessage: message, forGroupKey: (group?.key)!) { (success) in
            if !success {
                print("ChatViewController: Failed to upload Message.\n")
            }
            self.messageField.text = ""
            print("ChatViewController: Successfully uploaded Message")
        }
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let user = members[message.senderId]
        var cellID = ""

        if message.imageUrl == "" {
            cellID = message.senderId == Auth.auth().currentUser?.uid ? CID_USER_MESSAGE : CID_MESSAGE
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? MessageCell {
                cell.configure(withUser: user!, andContent: message.content)
                return cell
            }
        } else {
            cellID = message.senderId == Auth.auth().currentUser?.uid ? CID_USER_IMAGE_MESSAGE : CID_IMAGE_MESSAGE
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ImageMessageCell {
                cell.configure(withUser: user!, andContent: message.imageUrl)
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func scrollToEnd () {
        if messages.count == 0 { return }
        let endIndex = IndexPath(row: messages.count - 1, section: 0)
        self.messageTableView.scrollToRow(at: endIndex, at: .bottom, animated: false)
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imageButtonTapped () {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("ChatViewController: Did cancel image picker.")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker : UIImage?
        
        if let editiedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editiedImage
        }
        else if let originalImage = info["UIImagePickerControllerReferenceURL"] as? UIImage {
            selectedImageFromPicker = originalImage
        }

        if let selectedImage = selectedImageFromPicker {
            StorageService.instance.uploadImageToStorage(withImage: selectedImage, andFolderKey: SK_MESSAGE_IMG, completion: { (imageUrl) in
                let message = Message(senderId: (Auth.auth().currentUser?.uid)!, content: "", imageUrl: imageUrl)
                DatabaseService.instance.uploadPost(withMessage: message, forGroupKey: (self.group?.key)!, completion: { (success) in
                    if !success {
                        print("ChatViewController: Failed to upload Message.\n")
                        self.dismiss(animated: true, completion: nil)
                    }
                    self.dismiss(animated: true, completion: nil)
                    print("ChatViewController: Successfully uploaded Message")
                })
            })
        }
    }
}










