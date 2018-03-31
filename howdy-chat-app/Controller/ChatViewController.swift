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
    @IBOutlet weak var infoView : UIView!
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var addParticipantImg: UIImageView!
    
    var group : Group?
    var members = [String:User]()
    var messages = [Message]()
    var groupTitle = ""
    let MessageType = Message.MessageType.self

    struct MessagesForDay {
        var name : String!
        var messages = [Message]()
    }
    
    var messagesByDay = [MessagesForDay]()
    var infoHeight : NSLayoutConstraint!
    var infoOriginalHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self

        collectionView.delegate = self
        collectionView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notif:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notif:)), name: .UIKeyboardWillHide, object: nil)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gesturedForCloseKeyboard)))

        imagePickerButton.addTarget(self, action: #selector(imageButtonTapped), for: .touchUpInside)
        
        infoOriginalHeight = infoView.frame.height
        infoHeight = NSLayoutConstraint(item: infoView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        infoView.addConstraint(infoHeight)
        
        self.addParticipantImg.alpha = 0
        self.collectionView.alpha = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        groupTitle = (group?.title.uppercased())!
        groupTitleLabel.text = groupTitle

        DatabaseService.instance.REF_GROUPS.observe(.value) { (dataSnapShot) in
            let data = dataSnapShot.childSnapshot(forPath: (self.group?.key)! )
            guard let group = DatabaseService.instance.getGroup(withDataSnapShot: data) else { return }
            
            self.group = group
            
            DatabaseService.instance.getMembers(ids: self.group!.members) { (members) in
                self.members = members
                self.collectionView.reloadData()
                DatabaseService.instance.getMessagesFor(desiredGroup: self.group!, completion: { (messages) in
                    self.arrangeMessageByDate(messages: messages)
                    self.setThumbnailForMediaMessages()
                    self.getImagesForUsers()
                })
            }
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
        
        if notif.name == NSNotification.Name.UIKeyboardWillHide {
            self.inputViewBottomAncor.constant = 0
        } else if notif.name == NSNotification.Name.UIKeyboardWillShow{
            closeInfoView()
            self.inputViewBottomAncor.constant = -(notif.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
            self.scrollToEnd()
        }
        
        let duration = notif.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
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
    
    @IBAction func addMemberButtonTapped (_ sender: Any ) {
        guard let addVC = storyboard?.instantiateViewController(withIdentifier: SBID_ADD_PARTICIPANTS) as? AddParticipantsViewController else { return }
        addVC.usersToIgnore = Array(members.values)
        present(addVC, animated: true, completion: nil)
    }
    
    @IBAction func infoButtonTapped (_ sender: Any) {
        
        if self.infoView.frame.height < 50 {
            openInfoView()
        } else {
            closeInfoView()
        }

    }
    
    func openInfoView() {
        self.view.endEditing(true)
        
        infoHeight.constant = infoOriginalHeight
        
        UIView.animateKeyframes(withDuration: 0.4, delay: 0.0, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.75, animations: {
                self.view.layoutIfNeeded()
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25, animations: {
                self.addParticipantImg.alpha = 1
                self.collectionView.alpha = 1
            })
        }, completion: nil)
    }
    
    func closeInfoView() {
        infoHeight.constant = CGFloat(0)
        
        UIView.animateKeyframes(withDuration: 0.4, delay: 0.0, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25, animations: {
                self.addParticipantImg.alpha = 0
                self.collectionView.alpha = 0
            })
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.75, animations: {
                self.view.layoutIfNeeded()
            })
        }, completion: nil)
    }
    
    func setThumbnailForMediaMessages() {
        for day in self.messagesByDay.enumerated() {
            for (_, m) in day.element.messages.enumerated() {
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
    
    func addMembers ( users: [User] ) {
        if users.count == 0 { return }
        DatabaseService.instance.add(participants: users, toGroup: group!)
        var _text = "Added "
        
        for (index, user) in users.enumerated() {
            if index == 0 {
                _text.append(user.name.components(separatedBy: " ")[0])
            } else if index == users.count - 1 {
                _text.append(" and \(user.name.components(separatedBy: " ")[0])")
            } else {
                _text.append(", \(user.name.components(separatedBy: " ")[0])")
            }
        }
        
        _text.append(" to the group.")
        
        let message = Message(senderId: (Auth.auth().currentUser?.uid)!, type: MessageType.Text.rawValue, time: String( Int(NSDate().timeIntervalSince1970) ), content: _text)
        
        DatabaseService.instance.uploadPost(withMessage: message, forGroupKey: (self.group?.key)!) { (success) in
            if !success {
                print("ChatViewController: Failed to upload Message.\n")
            }
            print("ChatViewController: Successfully uploaded Message")
        }
    }
    
    @objc func gesturedForCloseKeyboard() {
        self.view.endEditing(true)
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
        guard let user = members[message.senderId] else { return UITableViewCell() }

        let info = [
            "chain" : indexPath.row > 0 && self.messagesByDay[indexPath.section].messages[indexPath.row - 1].senderId == message.senderId,
            "last" : indexPath.row == self.messagesByDay[indexPath.section].messages.count - 1 ||
                        indexPath.row < self.messagesByDay[indexPath.section].messages.count - 2 &&
                            self.messagesByDay[indexPath.section].messages[indexPath.row + 1].senderId != message.senderId
        ]
        
        
        if message.type == MessageType.Text {
            let cellID = message.senderId == Auth.auth().currentUser?.uid ? CID_USER_MESSAGE : CID_MESSAGE
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? MessageCell {
                cell.configure(user: user, message: message, info: info)
                return cell
            }
        } else {
            let cellID = message.senderId == Auth.auth().currentUser?.uid ? CID_USER_MEDIA_MESSAGE : CID_MEDIA_MESSAGE
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? MediaMessageCell {
                cell.configure(user: user, message: message, info: info)
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

extension ChatViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PARTICIPANTS_CELL_ID, for: indexPath) as? ContactCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(withUser: Array(members.values)[indexPath.row])
        return cell
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
        self.dismiss(animated: true, completion: nil)

        StorageService.instance.uploadVideoToStorage(withURL: url, andFolderKey: SK_MESSAGE_VID) { (_url) in
            let message = Message(senderId: (Auth.auth().currentUser?.uid)!, type: self.MessageType.Video.rawValue, time: String(Int(NSDate().timeIntervalSince1970)), content: _url)
            
            DatabaseService.instance.uploadPost(withMessage: message, forGroupKey: (self.group?.key)!, completion: { (success) in
                if !success {
                    print("ChatViewController: Failed to upload Message.\n")
                }
                print("ChatViewController: Successfully uploaded Message")
            })
        }
    }
}










