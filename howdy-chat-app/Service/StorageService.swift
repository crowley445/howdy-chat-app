//
//  StorageService.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 15/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import Foundation
import Firebase
import AVFoundation

let imageCache = NSCache<NSString, UIImage>()

class StorageService {
    
    static let instance = StorageService()
    
    let REF_STORAGE = Storage.storage().reference()
    let MessageType = Message.MessageType.self

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
    
    func uploadVideoToStorage (withURL videoURL: NSURL, andFolderKey key: String, completion: @escaping (_ vidUrl : String) -> ()) {
        REF_STORAGE.child(key).child("\(NSUUID().uuidString).mov").putFile(from: videoURL as URL, metadata: nil) { (metadata, error) in
            if let error = error {
                print("StorageService: Failed to upload video: \n \(error)")
                return
            }
            guard let videoURL = metadata?.downloadURL()?.absoluteString else { return }
            completion(videoURL)
        }
    }
    
    func getImageFromStorage( withURLString url: String, completion: @escaping (_ image: UIImage) -> ()) {
        if let image = imageCache.object(forKey: url as NSString) {
            completion(image)
        }
        
        guard  let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("StorageService: Failed to get profile image with URL. \n \(error)")
                return
            }
            
            var image = UIImage()
            
            if let imageData = data, let _image = UIImage(data: imageData) {
                image = _image
            } else {
                let asset = AVAsset(url: url)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                do{
                    image = UIImage(cgImage: try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil) )
                } catch {
                    completion(UIImage(named: IMG_DEFAULT_PROFILE_SML)!)
                }
            }
            
            imageCache.setObject(image, forKey: url.absoluteString as NSString)
            completion(image)
            
        }.resume() 
    }
    
    func getProfileImages( forUsers users: [User], completion: @escaping (_ users: [User]) -> ()) {
        var _users = [User]()
        for u in users.enumerated() {
            StorageService.instance.getImageFromStorage(withURLString: u.element.imageURL, completion: { (_image) in
                u.element.image = _image
                _users.append(u.element)
                if _users.count == users.count {
                    completion(_users)
                }
            })
        }
    }
    
    func getThumbnails( forMessages msgs: [Message], completion: @escaping(_ messages: [Message]) ->()) {
        var _msgs = [Message]()
        for m in msgs {
            if m.type == MessageType.Text { continue }
            StorageService.instance.getImageFromStorage(withURLString: m.content, completion: { (_image) in
                m.thumbnail = _image
                _msgs.append(m)
                if msgs.count == _msgs.count {
                    completion(_msgs)
                }
            })
        }
    }
}









