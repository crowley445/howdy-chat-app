//
//  HelperMethods.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 22/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import Foundation

class HelperMethods {
    static let instance = HelperMethods()
    let COLOR_WHEEL = [
        [#colorLiteral(red: 0.08235294118, green: 0.5843137255, blue: 0.7294117647, alpha: 1), #colorLiteral(red: 0.06666666667, green: 0.4705882353, blue: 0.6, alpha: 1), #colorLiteral(red: 0.06274509804, green: 0.3568627451, blue: 0.4784313725, alpha: 1), #colorLiteral(red: 0.05098039216, green: 0.2392156863, blue: 0.3294117647, alpha: 1)], [#colorLiteral(red: 0.7529411765, green: 0.1803921569, blue: 0.1215686275, alpha: 1), #colorLiteral(red: 0.8509803922, green: 0.3098039216, blue: 0.1254901961, alpha: 1), #colorLiteral(red: 0.9450980392, green: 0.4235294118, blue: 0.1294117647, alpha: 1), #colorLiteral(red: 0.937254902, green: 0.5450980392, blue: 0.1764705882, alpha: 1)], [#colorLiteral(red: 0.9333333333, green: 0.6666666667, blue: 0.231372549, alpha: 1), #colorLiteral(red: 0.9215686275, green: 0.7882352941, blue: 0.2666666667, alpha: 1), #colorLiteral(red: 0.6352941176, green: 0.7215686275, blue: 0.4274509804, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.6549019608, blue: 0.5764705882, alpha: 1)],[#colorLiteral(red: 0.7568627451, green: 0.5607843137, blue: 0.8509803922, alpha: 1), #colorLiteral(red: 0.6745098039, green: 0.4078431373, blue: 0.8039215686, alpha: 1), #colorLiteral(red: 0.5921568627, green: 0.2666666667, blue: 0.7411764706, alpha: 1), #colorLiteral(red: 0.4745098039, green: 0.2078431373, blue: 0.5960784314, alpha: 1)]
    ]
    func getColorForCell( last: UIColor? ) -> UIColor {
        
        guard let _last = last else { return COLOR_WHEEL[randomInt(under: COLOR_WHEEL.count)][randomInt(under: 4)] }
        
        var _random : Int
        
        repeat {
            _random = randomInt(under: COLOR_WHEEL.count)
        } while COLOR_WHEEL[_random].contains(_last) 
        
        return COLOR_WHEEL[_random][randomInt(under: 4)]
    }
    
    func randomInt(under: Int) -> Int {
        return Int( arc4random_uniform( UInt32(under) ) )
    }
    
}
