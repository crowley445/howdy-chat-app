//
//  GradientView.swift
//  smack
//
//  Created by Brian  Crowley on 16/11/2017.
//  Copyright © 2017 Brian Crowley. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {

    
    @IBInspectable var start: CGPoint = CGPoint(x: 0, y: 0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var end: CGPoint = CGPoint(x: 1, y: 1) {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var topColor: UIColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1) {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var bottomColor: UIColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1) {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.startPoint = start
        gradientLayer.endPoint = end
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
