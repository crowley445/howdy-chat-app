//
//  SharedGestureFunctions.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 08/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import Foundation
import UIKit

class SharedGestureFunctions {
    
    static let instance = SharedGestureFunctions()
    
    @objc func endEditingOnTap (recognizer: UITapGestureRecognizer) {
        recognizer.view?.endEditing(true)
    }

    @objc func dismissOnDownSwipe (recognizer: UISwipeGestureRecognizer) {
        
    }
}

