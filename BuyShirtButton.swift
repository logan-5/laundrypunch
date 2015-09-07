//
//  BuyShirtButton.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 9/5/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class BuyShirtButton: CCNode {

    var price: Int64 = 0
    var spriteName: String?
    var ready = false
    var rainbowAction: CCAction?
    var unlocked = false

    weak var sprite: CCSprite!
    weak var label: CCLabelTTF!

    func didLoadFromCCB() {
        ready = false
        self.userInteractionEnabled = false
    }

    func buyShirt() {
        self.unlocked = true
        Data.sharedData.unlockShirt( spriteName!, price: price )
    }

    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if ready && !unlocked && Data.sharedData.totalScore >= price {
            buyShirt()
            GameState.sharedState.audioEngine?.playEffect( "audioFiles/explosion.caf" )
        }
    }

    override func update(delta: CCTime) {
        if !ready && self.parent != nil && spriteName != nil {
            ready = true

            let pos = self.position
            self.positionType = CCPositionTypeMake( CCPositionUnit.Points, CCPositionUnit.Points, CCPositionReferenceCorner.BottomLeft )
            self.position = ccp(pos.x * self.parent.contentSizeInPoints.width, pos.y * self.parent.contentSizeInPoints.height)

            sprite.spriteFrame = CCSpriteFrame(imageNamed:"clothesSprites/"+spriteName!+".png")
            let maxSize = max(sprite.contentSize.width, sprite.contentSize.height)
            sprite.scale = Float(self.contentSizeInPoints.width / maxSize)
            sprite.anchorPoint = ccp( 0.5, 0 )
            sprite.position = ccp( self.contentSizeInPoints.width / 2, 0 )
            label.string = String(price)
            if Data.sharedData.isUnlocked( spriteName! ) { unlock() }

            self.userInteractionEnabled = true
        }
        if unlocked && rainbowAction == nil {
            var goldExplosion = CCBReader.load( "Effects/GoldExplosion" ) as! CCParticleSystem
            goldExplosion.autoRemoveOnFinish = true
            goldExplosion.position = label.positionInPoints
            self.addChild( goldExplosion )

            unlock()
            ( self.parent as! Unlockables ).updateShirtsToSpend()
        }
    }

    func unlock() {
        label.removeFromParent()
        rainbowAction = CCActionAnimateRainbow.instantiate( 1.2 )
        sprite.runAction( rainbowAction )
    }
}
