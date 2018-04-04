//
//  ActivityViewController.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 28/03/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {
    
    var visualEffectView : UIVisualEffectView!
    var effect : UIVisualEffect!
    var spinner : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        visualEffectView = UIVisualEffectView(frame: view.frame)
        visualEffectView.effect = nil
        spinner = UIActivityIndicatorView(frame: view.frame)
        spinner.activityIndicatorViewStyle = .whiteLarge
        view.addSubview(visualEffectView)
        view.addSubview(spinner)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }
    
    func animateIn() {
        UIView.animate(withDuration: 0.25, animations: {
            self.visualEffectView.effect = UIBlurEffect(style: .dark)
        }) { _ in
            self.spinner.startAnimating()
        }
        
    }
    
    func animateOut ( completion: @escaping CompletionHandler) {
        spinner.stopAnimating()
        UIView.animate(withDuration: 0.25, animations: {
            self.visualEffectView.effect = nil
        }) { _ in
            self.dismiss(animated: false, completion: {
                completion(true)
            })
        }
    }
}
