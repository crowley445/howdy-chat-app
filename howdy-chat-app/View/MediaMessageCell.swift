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
    @IBOutlet weak var aspectRatio: NSLayoutConstraint!
    
    var chatVC : ChatViewController!
    var message : Message!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.thumbnailImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleThumbnailTap(sender:))))
    }
    
    func configure( withUser user: User, andMessage message: Message, isPartOfChain isChain: Bool ) {
        
        self.message = message
        
        if let _nameLabel = self.nameLabel {
            _nameLabel.text = user.name.components(separatedBy: " ")[0]
            _nameLabel.isHidden = isChain
        }
        
        if let _image = message.thumbnail {
            self.thumbnailImageView.image = _image
            self.aspectRatio.constant = self.thumbnailImageView.frame.size.width * (_image.size.height / _image.size.width)
        }
        
        self.thumbnailImageView.layer.cornerRadius = 10
        self.thumbnailImageView.clipsToBounds = true
        self.thumbnailImageView.isUserInteractionEnabled = true
        self.thumbnailImageView.contentMode = .scaleToFill
        
        self.topConstraint.constant = isChain ? 0 : 50
        if let _chatBubble = self.thumbnailImageView.superview {
            _chatBubble.layer.cornerRadius = 10
            _chatBubble.layer.shadowRadius = 0.75
            _chatBubble.layer.shadowOpacity = 0.25
            _chatBubble.layer.shadowOffset = CGSize(width: 0, height: 1.75)
            _chatBubble.layer.shadowColor = UIColor.black.cgColor
        }
        
        self.profileImageView.image = user.image
        self.profileImageView.isHidden = isChain

        self.selectionStyle = .none
    }
    
    @objc func handleThumbnailTap( sender: UITapGestureRecognizer) {
        self.chatVC?.presentMediaMessageContent(message: self.message, imageView: self.thumbnailImageView)
    }
}
