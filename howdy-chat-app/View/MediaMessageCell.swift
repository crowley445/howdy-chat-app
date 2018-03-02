//
//  ImageMessageCell.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 19/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

class MediaMessageCell: UITableViewCell {

    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var profileImageView : UIImageView!
    @IBOutlet weak var thumbnailImageView : UIImageView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    func configure( withUser user: User, andMessage message: Message, isPartOfChain isChain: Bool ) {
        
        if let _nameLabel = self.nameLabel {
            _nameLabel.text = user.name.components(separatedBy: " ")[0]
        }
        
        if let _image = message.thumbnail {
            self.thumbnailImageView.image = _image
        }
        
        self.thumbnailImageView.layer.cornerRadius = 10
        self.thumbnailImageView.clipsToBounds = true
        self.topConstraint.constant = isChain ? 0 : 50

        if let _chatBubble = self.thumbnailImageView.superview {
            _chatBubble.layer.cornerRadius = 20
        }
        
        self.profileImageView.image = user.image
        self.profileImageView.isHidden = isChain
        
        self.selectionStyle = .none
    }

}
