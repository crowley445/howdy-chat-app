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
    @IBOutlet weak var profileImageView : UIImageView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImgHeight: NSLayoutConstraint!
    
    func configure( withUser user: User, andContent content: String, isChain: Bool ) {

        if let _nameLabel = self.nameLabel {
            _nameLabel.text = user.name.components(separatedBy: " ")[0]
            _nameLabel.isHidden = isChain
        }

        self.contentLabel.text = content
        self.profileImageView.image = user.image
        self.profileImageView.isHidden = isChain
        self.profileImgHeight.constant = isChain ? 1: 60
        self.topConstraint.constant = isChain ? 0 : 50

        if let _chatBubble = self.contentLabel.superview {
            _chatBubble.layer.cornerRadius = 10
        }

        self.selectionStyle = .none
    }
}
