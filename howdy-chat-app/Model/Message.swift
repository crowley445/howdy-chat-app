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

    init(senderId: String, content: String) {
        self.senderId = senderId
        self.content = content
    }
    
}
