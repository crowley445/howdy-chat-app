//
//  MediaViewController.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 21/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

class MediaViewController: UIViewController {

    var message: Message!
    let MessageType = Message.MessageType.self
    
    init(withMessage message: Message) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        if message.type == MessageType.Image {
            let imageView = UIImageView(frame: view.frame)
            imageView.image = message.thumbnail
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
        }
        
        let swipe = UISwipeGestureRecognizer(target: self, action:#selector(closeOnDownSwipe) )
        swipe.direction = .down
        view.addGestureRecognizer(swipe)
    }
    
    @objc func closeOnDownSwipe() {
        dismiss(animated: true, completion: nil)
    }
}







