//
//  Group.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 14/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import Foundation

class Group {
    
    public private(set) var title : String
    public private(set) var description : String
    public private(set) var key : String
    public private(set) var members = [String]()
    public private(set) var imageUrl : String
    
    var messages : [Message]?
    
    init(title: String, description: String, key: String, members: [String], imageUrl: String){
        self.title = title
        self.description = description
        self.key = key
        self.members = members
        self.imageUrl = imageUrl
    }

}
