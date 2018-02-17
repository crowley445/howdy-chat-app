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
    

    func configure (withGroup group: Group) {
        self.groupImageView.image = UIImage(named: IMG_DEFAULT_PROFILE_SML)
        self.titleLabel.text = group.title
        self.descriptionLabel.text = group.description
        
        DispatchQueue.global().async {
            StorageService.instance.getImageFromStorage(withURLString: group.imageUrl, completion: { (_image) in
                DispatchQueue.main.async {
                    self.groupImageView.image = _image
                }
            })
        }
    }
    
}
