//
//  StorageService.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 15/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import Foundation
import Firebase

let imageCache = NSCache<NSString, UIImage>()


class StorageService {
    
    static let instance = StorageService()
    
    let REF_STORAGE = Storage.storage().reference()

    func uploadImageToStorage (withImage image: UIImage, andFolderKey key: String, completion: @escaping (_ imgUrl : String) -> ()){
        guard let data = UIImageJPEGRepresentation(image, 0.1) else { return }
        REF_STORAGE.child(key).child("\(NSUUID().uuidString).jpg").putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                print("StorageService: Failed to upload image: \n \(error)")
                return
            }
            guard let imageURL = metadata?.downloadURL()?.absoluteString else { return }
            completion(imageURL)
        }
    }
    
    func getImageFromStorage( withURLString url: String, completion: @escaping (_ image: UIImage) -> ()) {
        if let image = imageCache.object(forKey: url as NSString) {
            print("CACHED:\n\(url)")
            completion(image)
        }else {
            print("NOT CACHED.")
        }
        
        guard  let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("StorageService: Failed to get profile image with URL. \n \(error)")
                return
            }
            
            if let imageData = data, let image = UIImage(data: imageData) {
                imageCache.setObject(image, forKey: url.absoluteString as NSString)
                completion(image)
            } else {
                completion(UIImage(named:IMG_DEFAULT_PROFILE_SML)!)
            }
            
        }.resume() 
    }
}









