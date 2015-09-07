//
//  Unlockables.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 9/5/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Unlockables: CCNode {

    weak var amountToSpendLabel: CCLabelTTF!

    func didLoadFromCCB() -> Void {
        self.cascadeOpacityEnabled = true
        updateShirtsToSpend()
        setUpShirts()
        self.opacity = 0
        let fadeIn = CCActionFadeIn.actionWithDuration( 0.3 ) as! CCAction
        self.runAction( fadeIn )

        self.userInteractionEnabled = true
    }

    func returnToPrevious() -> Void {
        let fadeOut = CCActionFadeOut.actionWithDuration( 0.3 ) as! CCAction
        let dispose = CCActionCallBlock.actionWithBlock( { () -> Void in
            self.removeFromParent()
        } )as! CCAction
        let s = CCActionSequence.actionWithArray([fadeOut, dispose]) as! CCAction
        self.runAction( s )
    }

    weak var shirt0: BuyShirtButton!
    weak var shirt1: BuyShirtButton!
    weak var shirt2: BuyShirtButton!
    weak var shirt3: BuyShirtButton!
    weak var shirt4: BuyShirtButton!
    weak var shirt5: BuyShirtButton!
    weak var shirt6: BuyShirtButton!
    weak var shirt7: BuyShirtButton!
    weak var shirt8: BuyShirtButton!
    weak var shirt9: BuyShirtButton!

    func setUpShirts() {
        // this is awful.  for some reason SpriteBuilder wouldn't let me do it.

        shirt0.spriteName = "tee"
        shirt0.price = 0

        shirt1.spriteName = "polo"
        shirt1.price = 25

        shirt2.spriteName = "lsbuttondown"
        shirt2.price = 75

        shirt3.spriteName = "ssbuttondown"
        shirt3.price = 150

        shirt4.spriteName = "girlshirt"
        shirt4.price = 300

        shirt5.spriteName = "girlstank"
        shirt5.price = 500

        shirt6.spriteName = "stripper"
        shirt6.price = 1000

        shirt7.spriteName = "pirate"
        shirt7.price = 2000

        shirt8.spriteName = "superhero"
        shirt8.price = 5000

        shirt9.spriteName = "lastshirt"
        shirt9.price = 8000
    }

/*
    func shirtButton1() -> Void { buyShirt( shirt1 ) }
    func shirtButton2() -> Void { buyShirt( shirt2 ) }
    func shirtButton3() -> Void { buyShirt( shirt3 ) }
    func shirtButton4() -> Void { buyShirt( shirt4 ) }
    func shirtButton5() -> Void { buyShirt( shirt5 ) }
    func shirtButton6() -> Void { buyShirt( shirt6 ) }
    func shirtButton7() -> Void { buyShirt( shirt7 ) }
    func shirtButton8() -> Void { buyShirt( shirt8 ) }
    func shirtButton9() -> Void { buyShirt( shirt9 ) }
    func shirtButton0() -> Void { buyShirt( shirt0 ) }

    func buyShirt( shirt: BuyShirtButton ) {
        if Data.sharedData.totalScore >= shirt.price {
            shirt.unlocked = true
            var shirtSprite = shirt.backgroundSpriteFrameForState( CCControlState.Normal )
            var shirtName = shirtSprite.textureFilename//.lastPathComponent//.stringByDeletingPathExtension

            Data.sharedData.unlockShirt( shirtName, price: shirt.price )
        }
    }

    override func update(delta: CCTime) {
        for shirt in self.children {
            if let s = shirt as? BuyShirtButton {
                if s.rainbowAction == nil && s.unlocked {
                    s.rainbowAction = CCActionAnimateRainbow.instantiate( 1.2 )
                    s.runAction( s.rainbowAction )

                    var goldExplosion = CCBReader.load( "Effects/GoldExplosion" ) as! CCParticleSystem
                    goldExplosion.autoRemoveOnFinish = true
                    goldExplosion.position = shirt.positionInPoints
                    self.addChild( goldExplosion )
                }
            }
        }
    }*/

    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        let failEffectSmell = CCBReader.load( "Effects/FailureSmell" ) as! CCParticleSystem
        failEffectSmell.autoRemoveOnFinish = true
        failEffectSmell.position = touch.locationInNode( self )
        self.addChild( failEffectSmell )
    }

    func updateShirtsToSpend() {
        amountToSpendLabel.string = String( Data.sharedData.totalScore )
    }
}
