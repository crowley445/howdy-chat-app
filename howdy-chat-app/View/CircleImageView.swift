//
//  CircleImageView.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 20/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

@IBDesignable
class CircleImageView: UIImageView {
    
    @IBInspectable
    public var borderRadius: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = self.borderRadius
        }
    }
    
    @IBInspectable
    public var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = self.borderColor.cgColor
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }
    
    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }
}
