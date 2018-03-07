//
//  CustomTextField.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 06/03/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    
    override func awakeFromNib() {
        setupView()
        super.awakeFromNib()
    }
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    func setupView () {
        if let placeholderText = self.placeholder {
            let placeholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
            self.attributedPlaceholder = placeholder
        }
    }

}
