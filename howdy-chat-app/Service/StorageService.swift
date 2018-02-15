//
//  StorageService.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 15/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import Foundation
import Firebase

class StorageService {
    
    static let instance = StorageService()
    
    let REF_PROFILE_IMG = Storage.storage().reference().child(SK_PROFILE_IMG)
    
    func uploadImageToStorage( image : UIImage, completion: @escaping (_ imgUrl : String) -> ()) {
        
        guard let data = UIImagePNGRepresentation(image) else { return }
        REF_PROFILE_IMG.child("\(NSUUID().uuidString).png").putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                print("StorageService: Failed to upload profile image: \n \(error)")
                return
            }
            guard let imageURL = metadata?.downloadURL()?.absoluteString else { return }
            completion(imageURL)
        }
    }
}
