//
//  User.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 12/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import Foundation
import UIKit

class User {
    
    var name : String
    var email : String
    var uid : String
    var image: UIImage
    
    init(name: String, email: String, uid: String) {
        self.name = name
        self.email = email
        self.uid = uid
        self.image = UIImage(named: "default-profile-sml")!
    }
    
}
