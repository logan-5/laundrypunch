//
//  CCActionAnimateRainbow.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 9/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class CCActionAnimateRainbow {
    
    static let tintSpeed: CCTime = 0.1
   
    class func instantiate() -> CCAction {
        let tintCyan = CCActionTintTo.actionWithDuration( tintSpeed, color: CCColor.cyanColor() ) as! CCActionTintTo
        let tintMagenta = CCActionTintTo.actionWithDuration( tintSpeed, color: CCColor.magentaColor() ) as! CCActionTintTo
        let tintYellow = CCActionTintTo.actionWithDuration( tintSpeed, color: CCColor.yellowColor() ) as! CCActionTintTo
        let s = CCActionSequence.actionWithArray([tintCyan, tintMagenta, tintYellow]) as! CCActionInterval
        return CCActionRepeatForever.actionWithAction( s ) as! CCAction
    }
}
