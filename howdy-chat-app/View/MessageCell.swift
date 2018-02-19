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
    
    func configure( withUser user: User, andContent content: String ) {
        
        if let _nameLabel = self.nameLabel {
            _nameLabel.text = user.name.components(separatedBy: " ")[0]
        }
        
        self.contentLabel.text = content
        self.profileImageView.image = UIImage(named: IMG_DEFAULT_PROFILE_SML)
        DispatchQueue.global().async {
            StorageService.instance.getImageFromStorage(withURLString: user.imageURL, completion: { (_image) in
                DispatchQueue.main.async {
                    self.profileImageView.image = _image
                }
            })
        }
    }    
}
