//
//  ContactCollectionViewCell.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 13/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

class ContactCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel : UILabel!
    
    func configure (withUser user: User) {        
        DispatchQueue.global().async {
            StorageService.instance.getImageFromStorage(withURLString: user.imageURL, completion: { (_image) in
                DispatchQueue.main.async {
                    self.nameLabel.text = user.name.components(separatedBy: " ")[0]
                    self.profileImageView.image = _image
                }
            })
        }
    }
}
