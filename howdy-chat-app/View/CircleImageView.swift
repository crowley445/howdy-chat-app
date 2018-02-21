//
//  CircleImageView.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 20/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

class CircleImageView: UIImageView {
    
    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }
}
