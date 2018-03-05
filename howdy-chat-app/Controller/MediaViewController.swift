//
//  MediaViewController.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 21/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

class MediaViewController: UIViewController {

    var image : UIImage!
    var startingRect: CGRect!
    var imageView: UIImageView!
    
    var leftConstraint : NSLayoutConstraint!
    var rightConstraint : NSLayoutConstraint!
    var topConstraint : NSLayoutConstraint!
    var bottomConstraint : NSLayoutConstraint!
    var ratioConstraint : NSLayoutConstraint!
    
    init(imageView: UIImageView) {
        self.image = imageView.image
        self.startingRect = imageView.superview?.convert(imageView.frame, to: nil)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpStartingPosition()
        setUpGestures()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = UIColor.clear

        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        
        leftConstraint = NSLayoutConstraint(item: self.imageView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0)
        rightConstraint = NSLayoutConstraint(item: self.imageView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0)
        topConstraint = NSLayoutConstraint(item: self.imageView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        bottomConstraint = NSLayoutConstraint(item: self.imageView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        self.view.addConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
        
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.black
        }) { _ in
            
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
            self.view.backgroundColor = UIColor.black
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    func setUpStartingPosition() {
        
        self.view.backgroundColor = UIColor.clear
        
        imageView = UIImageView(frame: self.startingRect)
        imageView.image = self.image
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        self.view.addSubview(imageView)
        
    }
    
    func setUpGestures() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeOnDownSwipe)))
    }
    
    @objc func closeOnDownSwipe() {
        
        self.leftConstraint.constant = startingRect.origin.x
        self.rightConstraint.constant = (startingRect.origin.x + startingRect.size.width) - UIScreen.main.bounds.width
        
        self.topConstraint.constant = startingRect.origin.y
        self.bottomConstraint.constant = (startingRect.origin.y + startingRect.size.height) - UIScreen.main.bounds.height
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.backgroundColor = UIColor.clear
            self.view.layoutIfNeeded()
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
        
    }
}







