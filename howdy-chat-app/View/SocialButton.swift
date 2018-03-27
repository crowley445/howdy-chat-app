//
//  SocialButton.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 27/03/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

@IBDesignable
class SocialButton: UIButton {

    @IBInspectable
    public var borderRadius: CGFloat = 1.0 {
        didSet {
            self.layer.borderWidth = self.borderRadius
        }
    }
    
    @IBInspectable
    public var borderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = self.borderColor.cgColor
        }
    }
    
}
