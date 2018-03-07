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

    struct MessagesForDay {
        var name : String!
        var messages = [Message]()
    }
    
    var messagesByDay = [MessagesForDay]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTableView.delegate = self
        messageTableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notif:)), name: .UIKeyboardWillChangeFrame, object: nil)
        imagePickerButton.addTarget(self, action: #selector(imageButtonTapped), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupTitleLabel.text = group?.title.uppercased()
        DatabaseService.instance.REF_GROUPS.observe(.value) { (dataSnapShot) in
            DatabaseService.instance.getMessagesFor(desiredGroup: self.group!, completion: { (messages) in
                self.arrangeMessageByDate(messages: messages)
                self.setThumbnailForMediaMessages()
                self.getImagesForUsers()
            })
        }
    }

    func arrangeMessageByDate( messages: [Message]) {
        var days = [Date]()
        var _messagesByDay = [MessagesForDay]()
        
        for m in messages {
            let date = Date(timeIntervalSince1970: (m.time as NSString).doubleValue)
            if days.count == 0 || !Calendar.current.isDate(date, inSameDayAs: days.last!) {
                days.append(date)
            }
        }
        
        for d in days {
            let _messages = messages.filter({ (m) -> Bool in
                Calendar.current.isDate(d, inSameDayAs: Date(timeIntervalSince1970: (m.time as NSString).doubleValue))
            })
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let _byDay = MessagesForDay(name: formatter.string(from: d), messages: _messages)
            _messagesByDay.append(_byDay)
        }
        
        self.messagesByDay = _messagesByDay
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
    
    func presentMediaMessageContent( message: Message, imageView: UIImageView) {
        if message.type == MessageType.Text { return }
        
        if message.type == MessageType.Image {
            let media = MediaViewController(imageView: imageView)
            media.modalPresentationStyle = .overCurrentContext
            present(media, animated: false, completion: nil)
        } else if message.type == MessageType.Video {
            guard let url = URL(string: message.content ) else { return }
            let player = AVPlayer(url: url)
            let controller = AVPlayerViewController()
            controller.player = player
            present(controller, animated: true, completion: {
                player.play()
            })
        }
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.messagesByDay.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messagesByDay[section].messages.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.messagesByDay[section].name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.messagesByDay[indexPath.section].messages[indexPath.row]
        let user = members[message.senderId]
        var cellID = ""
        let isChain = indexPath.row > 0 && self.messagesByDay[indexPath.section].messages[indexPath.row - 1].senderId == message.senderId

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
                cell.chatVC = self
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let _view = UIView()
        let _label = UILabel(frame: _view.frame)
        _label.textAlignment = .center
        
        _view.backgroundColor = UIColor.clear
        
        _label.attributedText = NSAttributedString(string: self.messagesByDay[section].name, attributes: [
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.font : UIFont(name: "Avenir-Heavy", size: _label.font.pointSize) ?? _label.font.fontName
            ])
        
        
        _label.translatesAutoresizingMaskIntoConstraints = false
        _view.addConstraints([
            NSLayoutConstraint(item: _label, attribute: .left, relatedBy: .equal, toItem: _view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: _label, attribute: .right, relatedBy: .equal, toItem: _view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: _label, attribute: .top, relatedBy: .equal, toItem: _view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: _label, attribute: .bottom, relatedBy: .equal, toItem: _view, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        
        _view.addSubview(_label)
        
        return _view
    }
    
    func scrollToEnd () {
        DispatchQueue.main.async{
            guard let _last = self.messagesByDay.last else { return }
            let endIndex = IndexPath(row: _last.messages.count - 1, section: self.messagesByDay.count - 1)
            self.messageTableView.scrollToRow(at: endIndex, at: .bottom, animated: false)
        }

    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imageButtonTapped () {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) ?
                            .camera : .photoLibrary
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
        
        self.dismiss(animated: true, completion: nil)

        StorageService.instance.uploadImageToStorage(withImage: image, andFolderKey: SK_MESSAGE_IMG, completion: { (imageUrl) in
            let message = Message(senderId: (Auth.auth().currentUser?.uid)!, type: self.MessageType.Image.rawValue, time: String(Int(NSDate().timeIntervalSince1970) ), content: imageUrl)
            
            DatabaseService.instance.uploadPost(withMessage: message, forGroupKey: (self.group?.key)!, completion: { (success) in
                if !success {
                    print("ChatViewController: Failed to upload Message.\n")
                }
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










