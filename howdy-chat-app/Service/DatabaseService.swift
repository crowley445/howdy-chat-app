//
//  DatabaseService.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 07/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import Foundation
import Firebase

class DatabaseService {
    
    static let instance = DatabaseService()
    
    private let REF_USER = Database.database().reference().child("user")
    
    func createDatabaseUser( uid : String, data: Dictionary<String, Any> ) {
        REF_USER.child(uid).updateChildValues(data)
    }
    
}

