//
//  GroupCell.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 12/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit
import Firebase

class GroupCell: UITableViewCell {
    
    @IBOutlet weak var groupImageView : UIImageView!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var descriptionLabel : UILabel!
    @IBOutlet weak var backgroundCard: UIView!
    
    let MessageType = Message.MessageType.self

    func configure (withGroup group: Group) {
        
        self.groupImageView.image = UIImage(named: IMG_DEFAULT_PROFILE_SML)
        self.titleLabel.text = group.title
        
        if let last_message = group.messages?.last {
            DatabaseService.instance.getUser(withUID: last_message.senderId, completion: { (user) in
                
                let name = user.uid == Auth.auth().currentUser?.uid ? "Me: " : "\(user.name.components(separatedBy: " ")[0]): "
                let message = last_message.type == self.MessageType.Text ? last_message.content : last_message.type.rawValue
                
                let _string = NSMutableAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont( name: "HelveticaNeue-Bold", size: 12.0 )! ])
                _string.append(NSAttributedString(string: message, attributes: [NSAttributedStringKey.font: UIFont( name: "HelveticaNeue", size: 12.0 )!]))

                self.descriptionLabel.attributedText = _string
            })
        }
      
        
        self.backgroundCard.layer.cornerRadius = 4
        self.backgroundCard.layer.shadowRadius = 0.75
        self.backgroundCard.layer.shadowOpacity = 0.25
        self.backgroundCard.layer.shadowOffset = CGSize(width: 0, height: 1.75)
        self.backgroundCard.layer.shadowColor = UIColor.black.cgColor
    
        DispatchQueue.global().async {
            StorageService.instance.getImageFromStorage(withURLString: group.imageUrl, completion: { (_image) in
                DispatchQueue.main.async {
                    self.groupImageView.image = _image
                }
            })
        }
        
        self.selectionStyle = .none
    }
    
    func responedToTap () {
        UIView.animate(withDuration: 0.15) {
            self.backgroundCard.alpha = 0.5
        }
    }
    
    func indicateSucces( completion: @escaping(_: Bool) -> ()) {
        UIView.animate(withDuration: 0.15, animations: {
            self.backgroundCard.alpha = 1
        }) { _ in
            completion(true)
        }
    }
    
}
