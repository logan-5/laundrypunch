//
//  LivesDisplay.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 9/5/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class LivesDisplay: CCNode {

    let padding: CGFloat = 3
    var lives: Int = GameState.sharedState.lives
    var ready = false

    func didLoadFromCCB() -> Void {
        setup()
    }

    func setup() -> Void {
        let shirtWidth = ( self.contentSize.width - CGFloat( GameState.sharedState.lives + 1 ) * padding ) / CGFloat( GameState.sharedState.lives )
        for var i = 0; i < lives; ++i {
            let shirt = CCBReader.load( "Shirt" ) as! Shirt
            shirt.physicsBody!.affectedByGravity = false
            shirt.physicsBody!.sensor = true
            shirt.physicsBody!.allowsRotation = false
            //shirt.contentSize = CGSizeMake( shirtWidth, self.contentSize.height )
            shirt.scale = Float(shirtWidth / shirt.contentSize.height)
            shirt.anchorPoint = ccp( 0.5, 0 )
            shirt.position = ccp( padding + CGFloat(i) * ( shirtWidth + padding ) + shirtWidth / 2, 0 )
            self.addChild( shirt )
            if shirt.rainbowAnimation != nil {
                shirt.stopAction( shirt.rainbowAnimation )
                //shirt.rainbowAnimation = nil
            }
            shirt.color = CCColor.grayColor()
            let rainbowTime: Double = Double(CCRANDOM_0_1() + 1 )
            if !GameState.sharedState.lowFXMode { shirt.runAction( CCActionAnimateRainbow.instantiate( rainbowTime ) ) }
        }
        ready = true
    }

    override func update(delta: CCTime) {
        if self.parent != nil && ready && !GameState.sharedState.lost && GameState.sharedState.lives != lives && self.children?.count > 0 {
            --lives
            var shirt: Shirt
            var i = 1
            repeat {
                let index = self.children.count - i++
                if index < 0 || index >= self.children.count { return }
                shirt = self.children[index] as! Shirt
            } while shirt.displayDying
            shirt.displayDying = true
//            shirt.fall()
            shirt.cascadeOpacityEnabled = true
            let fade = CCActionFadeOut.actionWithDuration( 0.2 ) as! CCActionFadeOut
            let destroy = CCActionCallBlock.actionWithBlock({ () -> Void in
                self.children.last?.removeFromParent()
            }) as! CCActionCallBlock
            shirt.runAction(CCActionSequence.actionWithArray([fade, destroy]) as! CCActionSequence )
        }
    }
}
