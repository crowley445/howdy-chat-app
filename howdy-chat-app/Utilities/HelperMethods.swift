//
//  HelperMethods.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 22/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import Foundation
import MobileCoreServices


public func imageActionSheet(presentImagePicker: @escaping (_:UIImagePickerControllerSourceType) ->()) -> UIAlertController {
    
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
        presentImagePicker(UIImagePickerControllerSourceType.camera)
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
        presentImagePicker(UIImagePickerControllerSourceType.photoLibrary)
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    return actionSheet
}

public func getImagePicker( source: UIImagePickerControllerSourceType, delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> UIImagePickerController  {
    let picker = UIImagePickerController()
    picker.allowsEditing = true
    picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
    picker.sourceType = source
    picker.delegate = delegate
    return picker
}

public func selectedImageFromPicker ( info: [String : Any] ) -> UIImage? {
    var selectedImageFromPicker : UIImage?
    
    if let editiedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
        selectedImageFromPicker = editiedImage
    }
    else if let originalImage = info["UIImagePickerControllerReferenceURL"] as? UIImage {
        selectedImageFromPicker = originalImage
    }

    return selectedImageFromPicker
}

public func errorAlert ( title: String, message: String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
    
    return alert
}

class HelperMethods {
    static let instance = HelperMethods()
    

    
//    func getTopViewController() -> UIViewController? {
//        if var topController = UIApplication.shared.keyWindow?.rootViewController {
//            while let presentedViewController = topController.presentedViewController {
//                topController = presentedViewController
//            }
//            return topController
//        }
//
//        return nil
//    }
}
