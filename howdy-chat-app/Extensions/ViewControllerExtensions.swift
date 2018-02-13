//
//  ViewControllerExtensions.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 13/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func presentDetail(_ viewControllerToPresent: UIViewController) {
        self.view.window?.layer.add(getTransition(duration: 0.3, type: kCATransitionPush, subtype: kCATransitionFromRight), forKey: kCATransition)
        present(viewControllerToPresent, animated: false, completion: nil)
    }
    
    func dismissDetail () {
        self.view.window?.layer.add(getTransition(duration: 0.3, type: kCATransitionPush, subtype: kCATransitionFromLeft), forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }
    
    private func getTransition(duration: Double, type: String, subtype: String) -> CATransition {
        let transition = CATransition()
        transition.duration = duration
        transition.type = type
        transition.subtype = subtype
        return transition
    }
}
