//
//  LintScreenQuarter.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 9/25/15.
//  Copyright © 2015 Apportable. All rights reserved.
//

import UIKit

class LintScreenQuarter: CCNode {

    let sprite: CCSprite
    let centValue: Int64
    let lintScreen: LintScreen

    init(lintScreen: LintScreen, centValue cValue: Int64 = 25) {
        sprite = CCSprite( imageNamed: "miscSprites/quarter.png" )
        self.lintScreen = lintScreen
        centValue = cValue

        super.init()

        self.contentSize = CGSizeMake( 50, 50 )
        self.addChild( sprite )
        sprite.scale = Float(self.contentSizeInPoints.width / sprite.contentSizeInPoints.width)
        self.userInteractionEnabled = true
    }

    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        lintScreen.pickUpQuarter( self )
        self.removeFromParent()
    }
}
