//
//  Message.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 14/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import Foundation

class Message {
    
    public private(set) var senderId: String
    public private(set) var content: String
    public private(set) var imageUrl: String
    public private(set) var image: UIImage?
    
    init(senderId: String, content: String, imageUrl: String?) {
        self.senderId = senderId
        self.content = content
        self.imageUrl = imageUrl ?? ""
    }
    
}
