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
        let a = [tintCyan, tintMagenta, tintYellow]
        let i = Int(arc4random_uniform( 2 ))
        let b = [a[i % 2], a[(i+1) % 2], a[(i+2) % 2]]
        let s = CCActionSequence.actionWithArray(b) as! CCActionInterval
        return CCActionRepeatForever.actionWithAction( s ) as! CCAction
    }

    class func instantiate( var speed: Double ) -> CCAction {
        let tintCyan = CCActionTintTo.actionWithDuration( speed, color: CCColor.cyanColor() ) as! CCActionTintTo
        let tintMagenta = CCActionTintTo.actionWithDuration( speed, color: CCColor.magentaColor() ) as! CCActionTintTo
        let tintYellow = CCActionTintTo.actionWithDuration( speed, color: CCColor.yellowColor() ) as! CCActionTintTo
        let a = [tintCyan, tintMagenta, tintYellow]
        let i = Int(arc4random_uniform( 2 ))
        let b = [a[i % 2], a[(i+1) % 2], a[(i+2) % 2]]
        let s = CCActionSequence.actionWithArray(b) as! CCActionInterval
        return CCActionRepeatForever.actionWithAction( s ) as! CCAction
    }
}
