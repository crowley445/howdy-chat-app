//
//  ChatViewController.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 14/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVKit

class ChatViewController: UIViewController {
    
    @IBOutlet weak var messageField : UITextField!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var groupTitleLabel: UILabel!
    @IBOutlet weak var inputViewBottomAncor: NSLayoutConstraint!
    @IBOutlet weak var imagePickerButton: UIButton!
    
    var group : Group?
    var members = [String:User]()
    var messages = [Message]()
    let MessageType = Message.MessageType.self

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
                self.setThumbnailForMediaMessages()
                self.getImagesForUsers()
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
        dismissDetail()
    }
    
    @IBAction func sendButtonTapped (_ sender: Any) {
        guard let content = messageField.text, messageField.text != "" else { return }
        let message = Message(senderId: (Auth.auth().currentUser?.uid)!, type: MessageType.Text.rawValue, time : String( Int(NSDate().timeIntervalSince1970) ), content: content)
        DatabaseService.instance.uploadPost(withMessage: message, forGroupKey: (group?.key)!) { (success) in
            if !success {
                print("ChatViewController: Failed to upload Message.\n")
            }
            self.messageField.text = ""
            print("ChatViewController: Successfully uploaded Message")
        }
    }
    
    func setThumbnailForMediaMessages() {
        for (_, m) in self.messages.enumerated() {
            if m.type == MessageType.Text { continue }
            StorageService.instance.getImageFromStorage(withURLString: m.content, completion: { (_image) in
                m.thumbnail = _image
                DispatchQueue.main.async {
                    self.messageTableView.reloadData()
                    self.scrollToEnd()
                }
            })
        }
    }

    func getImagesForUsers() {
        for (_, m) in self.members.enumerated() {
            StorageService.instance.getImageFromStorage(withURLString: m.value.imageURL, completion: { (_image) in
                m.value.image = _image
                DispatchQueue.main.async {
                    self.messageTableView.reloadData()
                    self.scrollToEnd()
                }
            })
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
        let isChain = indexPath.row > 0 && message.senderId == messages[indexPath.row - 1].senderId

        if message.type == MessageType.Text {
            cellID = message.senderId == Auth.auth().currentUser?.uid ? CID_USER_MESSAGE : CID_MESSAGE
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? MessageCell {
                cell.configure(withUser: user!, andContent: message.content, isChain: isChain)
                return cell
            }
        } else {
            cellID = message.senderId == Auth.auth().currentUser?.uid ? CID_USER_MEDIA_MESSAGE : CID_MEDIA_MESSAGE
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? MediaMessageCell {
                cell.configure(withUser: user!, andMessage: message, isPartOfChain: isChain)
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let _message = messages[indexPath.row]
        
        if _message.type == MessageType.Text { return }
        
        if _message.type == MessageType.Image {
            let mediaVC = MediaViewController(withMessage: _message)
            present(mediaVC, animated: true, completion: nil)
        } else if _message.type == MessageType.Video {
            guard let url = URL(string: _message.content ) else { return }
            let player = AVPlayer(url: url)
            let controller = AVPlayerViewController()
            controller.player = player
            present(controller, animated: true, completion: {
                player.play()
            })
        }
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
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            uploadToStorageAndCreateMediaPost(withNSURL: videoUrl)
        }
        
        var selectedImageFromPicker : UIImage?
        
        if let editiedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editiedImage
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }

        if let selectedImage = selectedImageFromPicker {
            uploadToStorageAndCreatMediaPost(withImage: selectedImage)
        }
    }
    
    func uploadToStorageAndCreatMediaPost( withImage image: UIImage) {
        StorageService.instance.uploadImageToStorage(withImage: image, andFolderKey: SK_MESSAGE_IMG, completion: { (imageUrl) in
            let message = Message(senderId: (Auth.auth().currentUser?.uid)!, type: self.MessageType.Image.rawValue, time: String(Int(NSDate().timeIntervalSince1970) ), content: imageUrl)
            
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
    
    func uploadToStorageAndCreateMediaPost ( withNSURL url: NSURL) {
        StorageService.instance.uploadVideoToStorage(withURL: url, andFolderKey: SK_MESSAGE_VID) { (_url) in
            let message = Message(senderId: (Auth.auth().currentUser?.uid)!, type: self.MessageType.Video.rawValue, time: String(Int(NSDate().timeIntervalSince1970)), content: _url)
            
            DatabaseService.instance.uploadPost(withMessage: message, forGroupKey: (self.group?.key)!, completion: { (success) in
                if !success {
                    print("ChatViewController: Failed to upload Message.\n")
                    self.dismiss(animated: true, completion: nil)
                }
                self.dismiss(animated: true, completion: nil)
                print("ChatViewController: Successfully uploaded Message")
            })
        }
    }
}










