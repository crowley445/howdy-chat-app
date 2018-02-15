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
    
    func configure( name: String, content: String ) {
        nameLabel.text = name
        contentLabel.text = content
    }
}
