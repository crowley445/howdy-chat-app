//
//  Message.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 14/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import Foundation



class Message {

    public enum MessageType : String {
        case Text = "text"
        case Image = "image"
        case Video = "video"
        case Audio = "audio"
        case Unrecognised = "unrecognised"
    }
    
    public private(set) var senderId: String
    public private(set) var content: String
    public private(set) var type: MessageType
    public private(set) var time: String
    public var thumbnail: UIImage?
    
    init(senderId: String, type: String, time: String, content: String){
        self.senderId = senderId
        self.type = Message.MessageType(rawValue: type) ?? .Unrecognised
        self.time = time
        self.content = content
    }
}
