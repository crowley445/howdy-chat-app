//
//  ContactTableViewCell.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 12/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    var user : User!
    
    func configure(withUser user : User, setSelected selected: Bool) {
        self.nameLabel.text = user.name
        self.checkImageView.isHidden = selected
        self.user = user
        self.profileImageView.image = user.image
    }
    
    func toggleCheckmark() {
        checkImageView.isHidden = !checkImageView.isHidden
    }
}
