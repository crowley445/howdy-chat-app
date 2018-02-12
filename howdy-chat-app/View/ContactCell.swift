//
//  ContactCell.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 12/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    var user : User!
    
    func configure(withUser user : User, setSelected selected: Bool) {
        self.user = user
        nameLabel.text = user.name
        checkImageView.isHidden = selected
    }
    
    func toggleCheckmark() {
        checkImageView.isHidden = !checkImageView.isHidden
    }
}
