//
//  Handle.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 8/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Handle: CCNode {
    weak var bouncer: Bouncer?
    weak var highlights: CCNode!
   
    func didLoadFromCCB() -> Void {
        self.userInteractionEnabled = true
        
        highlights.cascadeOpacityEnabled = true
        let fadeOut = CCActionFadeOut.actionWithDuration( 0.3 ) as! CCAction
        let fadeIn = CCActionFadeIn.actionWithDuration( 0.3 ) as! CCAction
        let blink = CCActionRepeatForever.actionWithAction( CCActionSequence.actionWithArray([fadeOut, fadeIn]) as! CCActionSequence ) as! CCAction
        highlights.runAction( blink )
    }
    
    override func touchBegan( touch: CCTouch!, withEvent event: CCTouchEvent! ) -> Void {
        GameState.sharedState.scene!.hasBeenTouched = true

        self.position = ccp( touch.locationInNode( self.parent ).x, self.position.y )
        bouncer!.updateAngle( self.position )
    }

    override func touchMoved( touch: CCTouch!, withEvent event: CCTouchEvent! ) -> Void {
        self.touchBegan( touch, withEvent: event )
    }
    
    override func update( delta: CCTime ) {
        if bouncer == nil && self.parent != nil {
            bouncer = GameState.sharedState.scene!.bouncer as? Bouncer
        }
    }
}
