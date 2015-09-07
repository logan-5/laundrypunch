//
//  Difficulty.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 9/4/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Difficulty: CCNode {

    weak var wussButton: CCButton!
    weak var tolerableButton: CCButton!
    weak var unreasonableButton: CCButton!
    weak var efficiencyButton: CCButton!

    func didLoadFromCCB() -> Void {
        self.cascadeOpacityEnabled = true
        self.opacity = 0
        let fadeIn = CCActionFadeIn.actionWithDuration( 0.3 ) as! CCAction
        self.runAction( fadeIn )

        self.userInteractionEnabled = true

        highlightDifficulty()
    }

    func easyMode() -> Void {
        GameState.sharedState.mode = GameState.Mode.Easy
        highlightDifficulty()
    }

    func mediumMode() -> Void {
        GameState.sharedState.mode = GameState.Mode.Medium
        highlightDifficulty()
    }

    func hardMode() -> Void {
        GameState.sharedState.mode = GameState.Mode.Hard
        highlightDifficulty()
    }

    func efficiencyMode() -> Void {
        GameState.sharedState.mode = GameState.Mode.Efficiency
        highlightDifficulty()
    }

    func returnToPrevious() -> Void {
        let fadeOut = CCActionFadeOut.actionWithDuration( 0.3 ) as! CCAction
        let dispose = CCActionCallBlock.actionWithBlock( { () -> Void in
            self.removeFromParent()
        } )as! CCAction
        let s = CCActionSequence.actionWithArray([fadeOut, dispose]) as! CCAction
        self.runAction( s )
    }

    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        let failEffectSmell = CCBReader.load( "Effects/FailureSmell" ) as! CCParticleSystem
        failEffectSmell.autoRemoveOnFinish = true
        failEffectSmell.position = touch.locationInNode( self )
        self.addChild( failEffectSmell )
    }

    func highlightDifficulty() {
        for button in self.children {
            button.stopAllActions()
            if let b = button as? CCButton {
                b.color = CCColor.whiteColor()
            }
        }
        switch GameState.sharedState.mode {
        case .Easy:
            wussButton.runAction( CCActionAnimateRainbow.instantiate( 1.5 ) )
        case .Medium:
            tolerableButton.runAction( CCActionAnimateRainbow.instantiate( 1.5 ) )
        case .Hard:
            unreasonableButton.runAction( CCActionAnimateRainbow.instantiate( 1.5 ) )
        case .Efficiency:
            fallthrough
        default:
            efficiencyButton.runAction( CCActionAnimateRainbow.instantiate( 1.5 ) )
        }
    }
}
