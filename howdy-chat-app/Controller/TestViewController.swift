//
//  ThumbnailViewController.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 21/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class TestViewController: UIViewController {

    @IBAction func buttonPressed(_ sender: Any) {
    
    
        guard let _url = URL(string: "https://firebasestorage.googleapis.com/v0/b/howdy-chat-app.appspot.com/o/message_video%2FFB8530BD-9B94-4EB9-B8C9-597E7BEF094C.mov?alt=media&token=293f5435-bca4-47fe-9db7-23bc27bf4fe4") else {
            return
        }
        
        let video = AVPlayer(url: _url)
        let player = AVPlayerViewController()
        player.player = video
        
        present(player, animated: true) {
            print("YES!\n")
            video.play()
        }
    
    
    }
    
    
    
    
    
    
    
    
    
}
