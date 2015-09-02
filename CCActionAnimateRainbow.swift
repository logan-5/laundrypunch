//
//  CCActionAnimateRainbow.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 9/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class CCActionAnimateRainbow {
    
    static let tintSpeed: CCTime = 0.05
   
    class func instantiate() -> CCAction {
        let tintRed = CCActionTintTo.actionWithDuration( tintSpeed, color: CCColor.redColor() ) as! CCActionTintTo
        let tintOrange = CCActionTintTo.actionWithDuration( tintSpeed, color: CCColor.orangeColor() ) as! CCActionTintTo
        let tintYellow = CCActionTintTo.actionWithDuration( tintSpeed, color: CCColor.yellowColor() ) as! CCActionTintTo
        let tintGreen = CCActionTintTo.actionWithDuration( tintSpeed, color: CCColor.greenColor() ) as! CCActionTintTo
        let tintBlue = CCActionTintTo.actionWithDuration( tintSpeed, color: CCColor.blueColor() ) as! CCActionTintTo
        let tintIndigo = CCActionTintTo.actionWithDuration( tintSpeed, color: CCColor.purpleColor() ) as! CCActionTintTo
        
        return CCActionSequence.actionWithArray([tintRed, tintOrange, tintYellow, tintGreen, tintBlue, tintIndigo]) as! CCActionSequence
    }
}
