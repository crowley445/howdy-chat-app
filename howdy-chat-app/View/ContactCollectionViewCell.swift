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
        self.profileImageView.image = user.image
        self.nameLabel.text = user.name.components(separatedBy: " ")[0]
    }
}
