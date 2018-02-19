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
    
    let REF_USERS = Database.database().reference().child(DBK_USERS)
    let REF_GROUPS = Database.database().reference().child(DBK_GROUPS)
    
    // WRITE
    
    func createDatabaseUser( uid : String, data: Dictionary<String, Any>, completion: @escaping CompletionHandler ) {
        REF_USERS.child(uid).updateChildValues(data) { (error, ref) in
            if let error = error {
                print("DatabaseService: Failed to create user with error: \n \(error)")
                completion(false)
            }
            completion(true)
        }
    }
    
    func createGroup(withTitle title: String, Description description: String, andImageUrl imageUrl: String, forUserIds ids: [String], completion: @escaping CompletionHandler) {
        REF_GROUPS.childByAutoId().updateChildValues([DBK_GROUP_TITLE: title, DBK_GROUP_DESCRIPTION: description, DBK_GROUP_IMAGE_URL: imageUrl, DBK_GROUP_MEMBERS: ids]) { (error, ref) in
            if let error = error {
                print("DatabaseService: Failed to create group with error: \n \(error)")
                completion(false)
            }
            completion(true)
        }
    }
    
    func uploadPost(withMessage message: Message, forGroupKey key: String, completion: @escaping CompletionHandler) {
        REF_GROUPS.child(key).child(DBK_GROUP_MESSAGES).childByAutoId().updateChildValues([DBK_MESSAGE_CONTENT: message.content, DBK_MESSAGE_SENDER_ID: message.senderId, DBK_MESSAGE_IMAGE_URL: message.imageUrl])
        completion(true)
    }

    // READ
    
    func getAllUsers(completion: @escaping(_ userArray: [User]) -> Void) {
        var userArray = [User]()
        REF_USERS.observe(.value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in snapshot {
                let name = user.childSnapshot(forPath: DBK_USER_NAME).value as! String
                let email = user.childSnapshot(forPath: DBK_USER_EMAIL).value as! String
                let uid = user.key
                let imageUrl = user.childSnapshot(forPath: DBK_USER_PHOTO_URL).value as! String
                let userObject = User(name: name, email: email, uid: uid, imageURL: imageUrl)
                if Auth.auth().currentUser?.uid != user.key {
                    userArray.append(userObject)
                }
            }
            completion(userArray)
        }
    }
    
    func getUser(withUID uid: String, completion: @escaping(_ user: User) -> ()) {
        REF_USERS.observeSingleEvent(of: .value) { (userSnapShot) in
            guard let userSnapShot = userSnapShot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapShot {
                if user.key == uid {
                    let name = user.childSnapshot(forPath: DBK_USER_NAME).value as! String
                    let email = user.childSnapshot(forPath: DBK_USER_EMAIL).value as! String
                    let uid = user.key
                    let imageUrl = user.childSnapshot(forPath: DBK_USER_PHOTO_URL).value as! String
                    
                    let userObject = User(name: name, email: email, uid: uid, imageURL: imageUrl)
                    completion(userObject)
                }
            }
        }
    }

    func getMembers( ids: [String], completion: @escaping(_ members: [String:User]) -> ()) {
        var members = [String:User]()
        REF_USERS.observeSingleEvent(of: .value) { (data) in
            guard let data = data.children.allObjects as? [DataSnapshot] else { return }
            for user in data {
                if !ids.contains(user.key) { continue }
                let name = user.childSnapshot(forPath: DBK_USER_NAME).value as! String
                let email = user.childSnapshot(forPath: DBK_USER_EMAIL).value as! String
                let uid = user.key
                let imageUrl = user.childSnapshot(forPath: DBK_USER_PHOTO_URL).value as! String
                
                members[user.key] = User(name: name, email: email, uid: uid, imageURL: imageUrl)
            }
            
            completion(members)
         }
    }
    
    func getAllGroups ( completion: @escaping (_ groupsArray: [Group]) -> ()) {
        var groupsArray = [Group]()
        REF_GROUPS.observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let groupSnapshot = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for group in groupSnapshot {
                guard let membersArray = group.childSnapshot(forPath: DBK_GROUP_MEMBERS).value as? [String] else { return }
                
                if membersArray.contains((Auth.auth().currentUser?.uid)!) {
                    
                    guard let title = group.childSnapshot(forPath: DBK_GROUP_TITLE).value as? String,
                            let description = group.childSnapshot(forPath: DBK_GROUP_DESCRIPTION).value as? String,
                                let imageUrl = group.childSnapshot(forPath: DBK_GROUP_IMAGE_URL).value as? String else { continue }
                    
                    let group = Group(title: title, description: description, key: group.key, members: membersArray, imageUrl: imageUrl)
                    groupsArray.append(group)
                    
                }
            }
            completion(groupsArray)
        }
    }

    func getMessagesFor (desiredGroup: Group, completion: @escaping (_ messages: [Message]) -> Void) {
        var messagesArray = [Message]()
        REF_GROUPS.child(desiredGroup.key).child(DBK_GROUP_MESSAGES).observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let messagesSnapshot = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for message in messagesSnapshot {
                guard let senderId = message.childSnapshot(forPath: DBK_MESSAGE_SENDER_ID).value as? String,
                        let content = message.childSnapshot(forPath: DBK_MESSAGE_CONTENT).value as? String,
                            let imageUrl = message.childSnapshot(forPath: DBK_MESSAGE_IMAGE_URL).value as? String else {
                    continue
                }
                
                let message = Message(senderId: senderId, content: content, imageUrl: imageUrl)
                messagesArray.append(message)
            }
            
            completion(messagesArray)
        }
    }
}
