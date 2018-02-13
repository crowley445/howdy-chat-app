//
//  ParticipantsCell.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 13/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

class ParticipantsCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel : UILabel!
    
    func configure (withUser user: User) {
        profileImageView.image = user.image
        nameLabel.text = user.name.components(separatedBy: " ")[0]
    }
}
