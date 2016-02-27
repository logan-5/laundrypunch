//
//  BouncerHandle.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 8/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class BouncerHandle: CCNode {
    weak var bouncer: Bouncer?
    weak var highlights: CCNode!
    var ready = false
    var bouncerSet = false
    var initialY: CGFloat!
    let minY: CGFloat = 0

    func didLoadFromCCB() -> Void {
        self.userInteractionEnabled = true
        
        highlights.cascadeOpacityEnabled = true
        let fadeOut = CCActionFadeOut.actionWithDuration( 0.3 ) as! CCAction
        let fadeIn = CCActionFadeIn.actionWithDuration( 0.3 ) as! CCAction
        let blink = CCActionRepeatForever.actionWithAction( CCActionSequence.actionWithArray([fadeOut, fadeIn]) as! CCActionSequence ) as! CCAction
        highlights.runAction( blink )

    }
    
    override func touchBegan( touch: CCTouch!, withEvent event: CCTouchEvent! ) -> Void {
        if GameState.sharedState.scene!.isPaused() { GameState.sharedState.scene!.pause() } // unpause if paused
        GameState.sharedState.scene!.hasBeenTouched = true

        let touchPoint = touch.locationInNode( self.parent )
        let y = max(min(touchPoint.y, initialY), minY)
        self.position = ccp( touchPoint.x, y )
        bouncer?.updateAngle( self.position )
    }

    override func touchMoved( touch: CCTouch!, withEvent event: CCTouchEvent! ) -> Void {
        self.touchBegan( touch, withEvent: event )
    }
    
    override func update( delta: CCTime ) {
        if self.parent != nil && !ready {
            ready = true
            let pos = self.position
            self.positionType = CCPositionTypeMake( CCPositionUnit.Points, CCPositionUnit.Points, CCPositionReferenceCorner.BottomLeft )
            self.position = ccp(pos.x * self.parent!.contentSizeInPoints.width, pos.y * self.parent!.contentSizeInPoints.height)
            initialY = self.position.y
        }
        if !bouncerSet && self.parent != nil {
            bouncer = GameState.sharedState.scene!.bouncer as Bouncer
            bouncerSet = true
        }
    }
}
