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
    @IBOutlet weak var timeLabel : UILabel!
    @IBOutlet weak var profileImageView : UIImageView!
    @IBOutlet weak var thumbnailImageView : UIImageView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    var chatVC : ChatViewController!
    var message : Message!
    
    let MessageType = Message.MessageType.self
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.thumbnailImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleThumbnailTap(sender:))))
    }
    
    func configure( user: User, message: Message, info : [String: Bool] ) {
        
        self.message = message
        
        self.topConstraint.constant = info["chain"]! ? 0 : 20
        
        if let _nameLabel = self.nameLabel {
            _nameLabel.text = info["chain"]! ? "" : user.name.components(separatedBy: " ")[0]
        }
        
        self.thumbnailImageView.layer.cornerRadius = 2
        self.thumbnailImageView.clipsToBounds = true
        self.thumbnailImageView.isUserInteractionEnabled = true
        self.thumbnailImageView.contentMode = .scaleToFill

        if let _image = message.thumbnail {
            
            self.thumbnailImageView.image = _image
            self.thumbnailImageView.subviews.forEach({ $0.removeFromSuperview() })
            self.imageHeight.constant = self.thumbnailImageView.frame.size.width * (_image.size.height / _image.size.width)

            if self.message.type == MessageType.Video {
                let play_image_view = UIImageView(frame: self.thumbnailImageView.frame)
                play_image_view.image = UIImage(named: "play_icon")
                play_image_view.contentMode = .scaleAspectFit
                self.thumbnailImageView.addSubview(play_image_view)
                
                play_image_view.translatesAutoresizingMaskIntoConstraints = false
                
                let _constant : CGFloat = self.thumbnailImageView.frame.size.width * 0.2
                
                let left = NSLayoutConstraint(item: play_image_view, attribute: .left, relatedBy: .equal, toItem: self.thumbnailImageView, attribute: .left, multiplier: 1, constant: _constant)
                
                let right = NSLayoutConstraint(item: play_image_view, attribute: .right, relatedBy: .equal, toItem: self.thumbnailImageView, attribute: .right, multiplier: 1, constant: -_constant)
                
                let top = NSLayoutConstraint(item: play_image_view, attribute: .top, relatedBy: .equal, toItem: self.thumbnailImageView, attribute: .top, multiplier: 1, constant: _constant)
                
                let bottom = NSLayoutConstraint(item: play_image_view, attribute: .bottom, relatedBy: .equal, toItem: self.thumbnailImageView, attribute: .bottom, multiplier: 1, constant: -_constant)
                
                self.thumbnailImageView.addConstraints([left, right, top, bottom])
                self.thumbnailImageView.layoutIfNeeded()
            }
        }
        
        
        if let _chatBubble = self.thumbnailImageView.superview {
            _chatBubble.layer.cornerRadius = 2
            _chatBubble.layer.shadowRadius = 0.75
            _chatBubble.layer.shadowOpacity = 0.25
            _chatBubble.layer.shadowOffset = CGSize(width: 0, height: 1.75)
            _chatBubble.layer.shadowColor = UIColor.black.cgColor
        }
        
        self.profileImageView.image = info["chain"]! ? nil : user.image
        self.profileImageView.backgroundColor = UIColor.clear
        
        if let _timeLabel = self.timeLabel {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            _timeLabel.text = info["last"]! ? formatter.string(from: Date(timeIntervalSince1970: Double(message.time)! )) : ""
        }
        
        self.selectionStyle = .none
    }
    
    @objc func handleThumbnailTap( sender: UITapGestureRecognizer) {
        self.chatVC?.presentMediaMessageContent(message: self.message, imageView: self.thumbnailImageView)
    }
}
