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
    
    func configure( withUser user: User, andMessage message: Message ) {
        
        if let _nameLabel = self.nameLabel {
            _nameLabel.text = user.name.components(separatedBy: " ")[0]
        }
        
        if let _image = message.thumbnail {
            self.thumbnailImageView.image = _image
        }
        
        self.thumbnailImageView.layer.cornerRadius = 4
        self.thumbnailImageView.clipsToBounds = true
        
        if let _chatBubble = self.thumbnailImageView.superview {
            _chatBubble.layer.cornerRadius = 4
        }
        
        self.profileImageView.image = user.image
        self.selectionStyle = .none
    }

}
