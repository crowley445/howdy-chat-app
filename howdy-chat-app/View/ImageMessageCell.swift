//
//  ImageMessageCell.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 19/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

class ImageMessageCell: UITableViewCell {

    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var profileImageView : UIImageView!
    @IBOutlet weak var messageImageView : UIImageView!
    
    func configure( withUser user: User, andContent content: String ) {
        
        if let _nameLabel = self.nameLabel {
            _nameLabel.text = user.name
        }
        
        self.profileImageView.image = UIImage(named: IMG_DEFAULT_PROFILE_SML)
        DispatchQueue.global().async {
            StorageService.instance.getImageFromStorage(withURLString: user.imageURL, completion: { (_profileImg) in
                StorageService.instance.getImageFromStorage(withURLString: content, completion: { (_messageImg) in
                    DispatchQueue.main.async {
                        self.profileImageView.image = _profileImg
                        self.messageImageView.image = _messageImg
                    }
                })
            })
        }
    }
}
