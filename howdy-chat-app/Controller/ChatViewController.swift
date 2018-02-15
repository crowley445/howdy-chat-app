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
    
    var group : Group?
    var messages = [Message]()
    var members = [String:User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTableView.delegate = self
        messageTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupTitleLabel.text = group?.title
        DatabaseService.instance.REF_GROUPS.observe(.value) { (dataSnapShot) in
            DatabaseService.instance.getMessagesFor(desiredGroup: self.group!, completion: { (messages) in
                self.messages = messages
                self.messageTableView.reloadData()
            })
        }
    }
    
    @IBAction func backButtonTapped (_ sender: Any) {
        print("ChatViewController: Back button tapped.\n")
        dismissDetail()
    }
    
    @IBAction func sendButtonTapped (_ sender: Any) {
        print("ChatViewController: Send button tapped.\n")
        guard let content = messageField.text, messageField.text != "" else { return }
        let message = Message(senderId: (Auth.auth().currentUser?.uid)!, content: content)
        DatabaseService.instance.uploadPost(withMessage: message, forGroupKey: (group?.key)!) { (success) in
            if !success {
                print("ChatViewController: Failed to upload Message.\n")
            }
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
        var cellID = ""
        var displayName = ""
        
        if message.senderId == Auth.auth().currentUser?.uid {
            cellID = CID_USER_MESSAGE
            displayName = "You"
        } else {
            cellID = CID_MESSAGE
            displayName = (members[message.senderId]?.name)!
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }
        
        cell.configure(name: displayName, content: message.content)
        return cell
    }
}










