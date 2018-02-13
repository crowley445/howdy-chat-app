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
    
    private let REF_USER = Database.database().reference().child("users")
    private let REF_GROUPS = Database.database().reference().child("groups")
    
    // WRITE
    
    func createDatabaseUser( uid : String, data: Dictionary<String, Any>, completion: @escaping CompletionHandler ) {
        REF_USER.child(uid).updateChildValues(data) { (error, ref) in
            if let error = error {
                print("DatabaseService: Failed to create user with error: \n \(error)")
                completion(false)
            }
            completion(true)
        }
    }
    
    func createGroup(withTitle title: String, forUserIds ids: [String], completion: @escaping CompletionHandler) {
        REF_GROUPS.childByAutoId().updateChildValues(["title": title, "participants": ids]) { (error, ref) in
            if let error = error {
                print("DatabaseService: Failed to create group with error: \n \(error)")
                completion(false)
            }
            completion(true)
        }
    }
    
    // READ
    
    func getUsers(completion: @escaping(_ userArray: [User]) -> Void) {
        var userArray = [User]()
        REF_USER.observe(.value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in snapshot {
                let name = user.childSnapshot(forPath: "name").value as! String
                let email = user.childSnapshot(forPath: "email").value as! String
                let uid = user.key
                let userObject = User(name: name, email: email, uid: uid)
                if Auth.auth().currentUser?.uid != user.key {
                    userArray.append(userObject)
                }
            }
            completion(userArray)
        }
    }
}













