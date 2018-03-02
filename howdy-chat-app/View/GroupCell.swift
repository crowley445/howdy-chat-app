//
//  GroupCell.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 12/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {
    
    @IBOutlet weak var groupImageView : UIImageView!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var descriptionLabel : UILabel!
    @IBOutlet weak var backgroundCard: UIView!

    func configure (withGroup group: Group) {
        self.groupImageView.image = UIImage(named: IMG_DEFAULT_PROFILE_SML)
        self.titleLabel.text = group.title
        self.descriptionLabel.text = group.description
        self.backgroundCard.layer.cornerRadius = 4
    
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
