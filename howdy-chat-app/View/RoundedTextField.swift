//
//  RoundedTextField.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 08/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedTextField: UITextField {

    @IBInspectable var cornerRadius: CGFloat = 3.0 {
        didSet {
            if isCircle { return }
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var isCircle: Bool = false {
        didSet{
            layer.cornerRadius = layer.frame.width / 2
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet{
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet{
            layer.borderColor = borderColor.cgColor
        }
    }
    
    let padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        setAppearance()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setAppearance()
    }
    
    func setAppearance () {
        
        if isCircle {
            layer.cornerRadius = 0.5 * layer.bounds.height
            clipsToBounds = true
        } else {
            layer.cornerRadius = cornerRadius
        }
        
        if let placeholderText = self.placeholder {
            let placeholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
            self.attributedPlaceholder = placeholder
        }
    }

}

