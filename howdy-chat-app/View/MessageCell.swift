//
//  MessageCell.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 14/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit
import Firebase

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var contentLabel : UILabel!
    @IBOutlet weak var timeLabel : UILabel!
    @IBOutlet weak var profileImageView : UIImageView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImgHeight: NSLayoutConstraint!
    
    func configure( user: User, message: Message, info: [String: Bool] ) {

        self.profileImgHeight.constant = info["chain"]! ? 0 : 60
        self.topConstraint.constant = info["chain"]! ? 0 : 40
        
        if let _nameLabel = self.nameLabel {
            _nameLabel.text = info["chain"]! ? "" : user.name.components(separatedBy: " ")[0]
        }

        self.contentLabel.text = message.content
        self.profileImageView.image = info["chain"]! ? nil : user.image
        
        if let _chatBubble = self.contentLabel.superview {
            _chatBubble.layer.cornerRadius = 2
        }

        if let _timeLabel = self.timeLabel {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            _timeLabel.text = formatter.string(from: Date(timeIntervalSince1970: Double(message.time)! ))
        }
        
        self.selectionStyle = .none
    }
    
}
